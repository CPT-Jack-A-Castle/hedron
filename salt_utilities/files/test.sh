#!/bin/sh

set -e

echo "Testing for deprecated unless test -f pattern. Use creates: instead."

# Doing against salt/ so we don't test ourselves and fail.
# grep -Fr 'unless: test -f' salt/ && false

echo "Looking for __pycache__ directories that should not exist."
find -L . -type d -name '__pycache__' | grep __pycache__ && false

echo "Testing for lines ending with a space."

grep -R ' $' --exclude-dir .git --exclude-dir dist --exclude '*.mozlz4' --exclude '*.png' . && false

echo "shellcheck'ing shell scripts."
find -L . -type f -name '*.sh' | while read -r shell_script; do
    shellcheck "$shell_script"
done

find -L . -type f -name 'nginx.conf' | while read -r nginx_file; do
    echo "Testing: $nginx_file"
    if ! /usr/sbin/nginx -t -p "$(dirname "$nginx_file")" -c "$(basename "$nginx_file")" 2>&1 | grep 'syntax is ok'; then
        /usr/sbin/nginx -t -p "$(dirname "$nginx_file")" -c "$(basename "$nginx_file")"
        false
    fi
done

# So this breaks on # service files and if it can't find a service in that path. Better to check with check_cmd.
#echo 'Verifying Systemd files'
#find -L . -type f -name '*.service' -o -name "*.timer" -o -name "*.path" | grep -vF '@' | while read -r systemd_file; do
#    systemd-analyze verify "$systemd_file"
#done

echo 'flake8ing python files.'
find -L . -type f -name '*.py' | while read -r python_script; do
    flake8 "$python_script"
done

echo 'nosetesting where possible.'
find -L . -type f -name '*test.py' | while read -r test_python_script; do
    # PATH override is for sh imports. We want them to fail if absent in production, but not
    # in testing.
    PATH="$PATH:salt/hedron/stub_bin" nosetests-3.4 --no-byte-compile -vx "$test_python_script"
done

echo "Testing preseeds."
find -L . -type f -name '*.debian_preseed' | while read -r debian_preseed; do
    # First line is a benign warning about not being able to open a password database file.
    output=$(debconf-set-selections -c "$debian_preseed" 2>&1 | tail -n +2)
    echo "$debian_preseed: $output"
    [ -z "$output" ]
done

echo 'Testing dhcpd.conf files...'
find -L . -type f -name 'dhcpd.conf' | while read -r dhcpd_config; do
    /usr/sbin/dhcpd -f -t -cf "$dhcpd_config"
done

echo 'Testing ngircd.conf files...'
find -L . -type f -name 'ngircd.conf' | while read -r ngircd_config; do
    echo | /usr/sbin/ngircd -p -n -t -f "$(pwd)/$ngircd_config"
done

find -L . -type f -name 'sshd_config' | while read -r sshd_config; do
    /usr/sbin/sshd -t -f "$sshd_config"
done

find -L . -type f -name '*.json' | while read -r json_file; do
    echo "Testing: $json_file"
    python -m json.tool < "$json_file" > /dev/null
done


# Too duplicated.
# state.show_top doesn't return 1 if there's an error.
# Try to grab criticals and bail out if we do
echo 'state.show_top...'
salt-call --retcode-passthrough -c salt/hedron/salt_utilities/files/ --local --log-file=/dev/null state.show_top 2>&1 | grep CRITICAL && false

sleep 2

# This is very slow, unfortunately. Not very effective, either.
find -L ./salt -type f -name '*.sls' | grep -vF './salt/top.sls' | grep -vF './git/' | grep -vF './salt/pillar' | grep -vF './salt/private_pillar' | grep -vF './salt/hedron/example_pillar' | while read -r salt_state_file; do
    # Clean file name for salt use.
    salt_state=$(echo "$salt_state_file" | cut -d / -f 3- | cut -d . -f 1 | tr / . | sed 's/.init$//')
    echo "Processing: $salt_state"
    salt-call --retcode-passthrough -c salt/hedron/salt_utilities/files/ --local --log-file=/dev/null state.show_sls "$salt_state"
done

echo Success

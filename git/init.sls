hedron_git_package_installed:
  pkg.installed:
    - name: git

hedron_git_group:
  group.present:
    - name: git

hedron_git_user:
  user.present:
    - name: git
    - gid_from_name: True
    - home: /repo
    - createhome: False
    - shell: /usr/bin/git-shell

hedron_git_directory:
  file.directory:
    - name: /repo
    - mode: 0750
    - group: git

{% if 'hedron.git' in pillar %}
{% if 'public_key' in pillar['hedron.git'] %}
hedron_git_authorized_keys:
  file.managed:
    - name: /repo/.ssh/authorized_keys
    - contents_pillar: hedron.git:public_key
    - makedirs: True
{% endif %}

{% if 'repositories' in pillar['hedron.git'] %}
{% for repository in pillar['hedron.git']['repositories'] %}
hedron_git_create_repo_{{ repository }}:
  cmd.run:
    - name: git init --bare /repo/{{ repository }}.git
    - creates: /repo/{{ repository }}.git
{% endfor %}
{% endif %}
{% endif %}

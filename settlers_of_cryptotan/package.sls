include:
  - .pip_dependencies

hedron_settlers_of_cryptotan_package_installed:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/settlers_of_cryptotan.py
    - source: salt://hedron/settlers_of_cryptotan/files/settlers_of_cryptotan.py
    - mode: 0644

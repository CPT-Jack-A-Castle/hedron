import hedron_python_dist_path


def test_main():
    grain = hedron_python_dist_path.main()['hedron_python_dist_path']
    assert 'dist-packages' in grain
    assert 'python3' in grain

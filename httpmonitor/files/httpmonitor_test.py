import httpmonitor


def test_probe():
    # assert httpmonitor.probe('sejnfjrq6szgca7v.onion') is True
    assert httpmonitor.probe('httpbin.org') is True
    assert httpmonitor.probe('8.8.8.8') is False
    assert httpmonitor.probe('notavaliddomainithink.tld') is False

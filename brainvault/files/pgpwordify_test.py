from pgpwordify import (EVEN_WORDS,
                        ODD_WORDS,
                        pgpwordify)


def test_even_words():
    assert EVEN_WORDS[0] == 'aardvark'
    assert EVEN_WORDS[255] == 'zulu'


def test_odd_words():
    assert ODD_WORDS[0] == 'adroitness'
    assert ODD_WORDS[255] == 'yucatan'


def test_pgpwordify():
    assert pgpwordify(b'\x00') == 'aardvark'
    assert pgpwordify(b'\xFF') == 'zulu'
    assert pgpwordify(b'\x00\x00') == 'aardvarkadroitness'
    assert pgpwordify(b'\xFF\xFF') == 'zuluyucatan'
    assert pgpwordify(b'\x00\xFF\x00\xFF') == 'aardvarkyucatanaardvarkyucatan'
    assert pgpwordify(b'\x00\xFF', separator=' ') == 'aardvark yucatan'
    assert pgpwordify(b'\x00\xFF', separator='_') == 'aardvark_yucatan'
    assert pgpwordify(b'\x00', separator=' ') == 'aardvark'

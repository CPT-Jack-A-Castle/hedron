from nose.tools import raises

from hedron import validate_bootorder


def test_validate_bootorder():
    assert validate_bootorder('n') is True
    assert validate_bootorder('c') is True
    assert validate_bootorder('nc') is True
    assert validate_bootorder('cn') is True


@raises(TypeError)
def test_validate_bootorder_wrong_type():
    validate_bootorder(0)


@raises(ValueError)
def test_validate_bootorder_bad_value_1():
    validate_bootorder('nca')


@raises(ValueError)
def test_validate_bootorder_bad_value_2():
    validate_bootorder('cc')


@raises(ValueError)
def test_validate_bootorder_bad_value_3():
    validate_bootorder('')


@raises(ValueError)
def test_validate_bootorder_bad_value_4():
    validate_bootorder('anc')

import notbit

from sh import ErrorReturnCode_1
from nose.tools import raises
from mock import patch


keys_dot_dat = """[BM-87]
label =

[BM-88]
label =

[BM-89]
label =
"""


def test_sendmail_format():
    """
    Test _sendmail_format()
    """
    valid_message = """From: BM-from@bitmessage
To: BM-to@bitmessage

message"""
    assert notbit._sendmail_format('BM-from',
                                   'BM-to',
                                   'message') == valid_message
    valid_message = """From: BM-from@bitmessage
To: BM-to@bitmessage
Subject: Hello Subjective

message"""
    assert notbit._sendmail_format('BM-from',
                                   'BM-to',
                                   'message',
                                   'Hello Subjective') == valid_message


@raises(ErrorReturnCode_1)
@patch('notbit._read_keys_dot_dat')
def test_send_message_not_running(mock_read_keys_dot_dat):
    """
    Test failing send_message()

    Assuming this is being ran on a machine where this will break.
    Does test a couple code paths, thankfully.
    """
    mock_read_keys_dot_dat.return_value = keys_dot_dat
    notbit.send_message('BM-invalid', 'foo')


@raises(ErrorReturnCode_1)
@patch('notbit._read_keys_dot_dat')
def test_send_message_with_subject_not_running(mock_read_keys_dot_dat):
    """
    Test failing send_message() with a subject
    """
    mock_read_keys_dot_dat.return_value = keys_dot_dat
    notbit.send_message('BM-invalid', 'foo', 'Subject')


@patch('notbit._read_keys_dot_dat')
def test_get_from_address_and_addresses(mock_read_keys_dot_dat):
    mock_read_keys_dot_dat.return_value = keys_dot_dat
    assert notbit._get_from_address() == 'BM-87'
    assert notbit._get_all_from_addresses() == ['BM-87', 'BM-88', 'BM-89']


@patch('notbit._read_keys_dot_dat')
@raises(ValueError)
def test_get_from_all_addresses_bad_keys_dot_dat(mock_read_keys_dot_dat):
    mock_read_keys_dot_dat.return_value = '[haha nothing here'
    notbit._get_all_from_addresses()

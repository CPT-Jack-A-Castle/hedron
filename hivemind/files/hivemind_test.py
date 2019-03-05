import hivemind

from mock import patch


@patch('hivemind.journalctl_all_logs')
@patch('hivemind.journalctl_critical_logs')
def test_grab_alert_if_alertable(mock_critical_logs, mock_all_logs):
    mock_critical_logs.return_value = None
    mock_all_logs.return_value = 'DEBUG, not too critical.'
    assert hivemind.grab_alert_if_alertable() is None

    critical_log_line = '2017-01-01 CRITICAL ship burning'
    all_logs = '{}\n2017-01-01 Other logs'.format(critical_log_line)
    mock_all_logs.return_value = all_logs
    expected_output = critical_log_line
    output = hivemind.grab_alert_if_alertable()
    assert output == expected_output

    traceback_log_line = '2017-01-01 Traceback ship burning'
    all_logs = '{}\n2017-01-01 Other logs'.format(traceback_log_line)
    mock_all_logs.return_value = all_logs
    expected_output = traceback_log_line
    output = hivemind.grab_alert_if_alertable()
    assert output == expected_output

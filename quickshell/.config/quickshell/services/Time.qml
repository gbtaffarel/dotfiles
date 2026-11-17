pragma Singleton

import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    function format(fmt) {
        return Qt.formatDateTime(clock.date, fmt);
    }

    function formatLocalized(fmt, loc) {
        var targetLocale = loc ? loc : Qt.locale("pt_BR");
        return clock.date.toLocaleDateString(targetLocale, fmt);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}

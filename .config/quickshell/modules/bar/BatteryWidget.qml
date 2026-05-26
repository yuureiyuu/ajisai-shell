import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../utils"
import "../../components"

RowLayout {
    spacing: 1

    Text {
        text: {
            if (Config.useRealBattery && Battery.available) {
                return Math.round(Battery.percentage * 100);
            } else if (!Config.useRealBattery) {
                return "100";
            } else {
                // If not available and using real battery, display 0%
                return 0;
            }
        }
        font.pixelSize: 18
        color: Theme.text
    }

    LucideIcon {
        Layout.preferredWidth: 31
        Layout.preferredHeight: 28
        iconSize: 29
        color: Battery.isCharging ? Theme.iconActive : Theme.icon
        icon: {
            if (!Config.useRealBattery)
                return Icons.batteryFull;
            if (!Battery.available)
                return Icons.batteryWarning;

            var p = Battery.percentage * 100;

            if (Battery.isCharging)
                return Icons.batteryCharging;
            if (p >= 90)
                return Icons.batteryFull;
            if (p >= 60)
                return Icons.batteryMedium;
            if (p >= 20)
                return Icons.battery;
            if (p >= 0)
                return Icons.batteryLow;
            return Icons.batteryWarning;
        }
    }
}

import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../utils"

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

    Image {
        sourceSize.width: 25
        sourceSize.height: 25
        source: {
            if (!Config.useRealBattery)
                return "../../assets/battery-100.svg";
            if (!Battery.available)
                return "../../assets/battery-missing.svg";

            var p = Battery.percentage * 100;

            if (Battery.isCharging)
                return "../../assets/battery-charging.svg";
            if (p >= 90)
                return "../../assets/battery-100.svg";
            if (p >= 60)
                return "../../assets/battery-70.svg";
            if (p >= 20)
                return "../../assets/battery-30.svg";
            if (p >= 0)
                return "../../assets/battery-low.svg";
            return "../../assets/battery-missing.svg";
        }
    }
}

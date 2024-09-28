#!/bin/sh
set -e

if [ ! -z "$ZIGBEE2MQTT_DATA" ]; then
    DATA="$ZIGBEE2MQTT_DATA"
else
    DATA="/app/data"
fi

echo "Using '$DATA' as data directory"

if [ ! -f "$DATA/configuration.yaml" ]; then
    echo "Creating configuration file..."
    cp /app/configuration.example.yaml "$DATA/configuration.yaml"
fi

DATABASE="${DATA:?}/database.db"
case `file -b -i "${DATABASE:?}"` in
    application/*json|application/*jason)
        echo "Database seems sane..."
        ;;
    *)
        DATABASE_BACKUP="${DATABASE:?}.`date -Isec`~"
        if mv "${DATABASE:?}" "${DATABASE_BACKUP:?}"
        then
            echo "WARNING: Corrupt database has renamed to '${DATABASE_BACKUP:-N/A}'..." 1>&2
        else
            echo "WARNING: Removing corrupt database..." 1>&2
            rm "${DATABASE:?}" || true
        fi
        if ( : > "${DATABASE:?}" )
        then
            echo "Starting with empty database..." 
        else
            echo "WARNING: Could not create empty database!" 1>&2
        fi
        ;;
esac

exec "$@"

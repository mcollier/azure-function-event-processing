using System;

namespace EventStreamProcessing.Models
{
    public class SensorDataRecord
    {
        public Sensor Sensor { get; set; }

        public DateTimeOffset EnqueuedTime { get; set; }

        public DateTime ProcessedTime { get; set; }

        public string PartitionKey { get; set; }
        public string RowKey { get; set; }
    }
}

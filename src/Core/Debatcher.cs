using Azure.Messaging.EventHubs;

using EventStreamProcessing.Helpers;
using EventStreamProcessing.Helpers.Extensions;

using Microsoft.Extensions.Logging;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Xml.XPath;

namespace EventStreamProcessing.Core
{
    public class Debatcher
    {
        private ILogger _log;

        public Debatcher(ILogger log)
        {
            _log = log;
        }

        public EventData[] Debatch(EventData[] inputMessages, string partitionId)
        {
            var sensorType = Environment.GetEnvironmentVariable("SENSOR_TYPE");

            _log.LogBatchSize("DebatchingFunction", inputMessages.Length);

            List<EventData> outputMessages = new();

            foreach (EventData message in inputMessages)
            {
                try
                {
                    var messageBody = message.EventBody.ToString();

                    var messageXml = XDocument.Parse(messageBody);
                    var sensors = messageXml.XPathSelectElements($"//devices/sensor[starts-with(@type, '{sensorType}')]");

                    if (!sensors.Any())
                    {
                        // Log that we're skipping this message
                        _log.LogInformation($"No sensors matching {sensorType} in this message, skipping");
                    }
                    else
                    {
                        foreach (XElement sensor in sensors)
                        {
                            var outputMessage = new EventData(Encoding.UTF8.GetBytes(Conversion.ConvertXmlToString(sensor)));

                            if (message.SystemProperties.ContainsKey("x-opt-enqueued-time"))
                            {
                                outputMessage.Properties.Add("InputEH_EnqueuedTimeUtc", message.SystemProperties["x-opt-enqueued-time"]);
                            }

                            // TODO: What to do?
                            //outputMessage.SystemProperties = message.SystemProperties;
                            // Add output message and increment count
                            outputMessages.Add(outputMessage);

                            // Log success
                            _log.LogEventProcessed(partitionId, message);
                        }
                    }
                }
                catch (Exception e)
                {
                    _log.LogProcessingError(e, "DebatchingFunction", partitionId, message);
                }
            }

            _log.LogProcessingComplete("DebatchingFunction", inputMessages.Length, outputMessages.Count, partitionId);
            return outputMessages.ToArray();
        }
    }
}
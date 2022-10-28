using EventStreamProcessing.Helpers;

using System;

using Xunit;

namespace EventStreamProcessingTests.Helpers
{
    public class TimeCalculationsTests
    {
        [Fact]
        public void GetLatency_TwoTimes_ReturnsLatencyInMs()
        {
            // Arrange
            var now = DateTime.Now;
            
            // Act
            var latency = TimeCalculations.GetLatency(now, now.AddMilliseconds(1000));

            // Assert
            Assert.Equal(1000, latency);
        }

        [Fact]
        public void GetLatency_StartTimeGreaterThanEndTime_ThrowsException()
        {
            // Arrange
            var now = DateTime.Now;
            
            // Act
            // Assert
            var exception = Assert.Throws<ArgumentException>(() => TimeCalculations.GetLatency(now.AddMilliseconds(1000), now));
            Assert.Equal("'startTime' must be before 'endTime'", exception.Message);
        }
    }
}
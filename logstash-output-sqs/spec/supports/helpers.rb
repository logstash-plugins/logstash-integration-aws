require 'aws-sdk'

# Retrieve all available messages from the specified queue.
#
# Rather than utilizing `Aws::SQS::QueuePoller` directly in order to poll an
# SQS queue for messages, this method retrieves and returns all messages that
# are able to be received from the specified SQS queue.
def receive_all_messages(queue_url, options = {})
  options[:idle_timeout] ||= 0
  options[:max_number_of_messages] ||= 10

  messages = []
  poller = Aws::SQS::QueuePoller.new(queue_url, options)

  poller.poll do |received_messages|
    messages.concat(received_messages)
  end

  messages
end

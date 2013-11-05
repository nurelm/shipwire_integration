require File.expand_path(File.dirname(__FILE__) + '/lib/ship_wire.rb')
Dir['./lib/**/*.rb'].each { |f| require f }

class ShipwireEndpoint < EndpointBase
  set :logging, true

  post '/send_shipment' do
    begin
  	  shipment_entry = ShipmentEntry.new(@message[:payload], @message[:message_id], @config)
  	  response  = shipment_entry.consume

  	  msg = success_shipment_notification(response)
  	  code = 200
    rescue => e
      msg = error_notification(e)
      code = 500
    end

    process_result code, base_msg.merge(msg)
  end

  post '/tracking' do
    begin
      shipment_tracking = ShipmentTracking.new(@message[:payload], @message[:message_id], @config)
      response = shipment_tracking.consume

      msg = success_tracking_notification(response)
      code = 200
    rescue => e
      msg = error_notification(e)
      code = 500
    end

    process_result code, base_msg.merge(msg)
  end

  private
  def base_msg
  	{ 'message_id' => @message[:message_id] }
  end

  def success_shipment_notification(response)
    { notifications:
      [
      	{ level: 'info',
          subject: 'Successfully sent shipment to Shipwire',
          description: 'Successfully sent shipment to Shipwire' }
      ]
    }.merge(response)
  end

  def success_tracking_notification(response)
    { notifications:
      [
      	{ level: 'info',
          subject: 'Successfully sent shipment tracking information to shipwire',
          description: 'Successfully sent shipment tracking information to shipwire' }
      ]
    }.merge(response)
  end

  def error_notification(e)
    { notifications:
      [
      	{
          level: 'error',
          subject: e.message.strip,
          description: { "backtrace" => e.backtrace }.to_s
        }
      ]
    }
  end
end

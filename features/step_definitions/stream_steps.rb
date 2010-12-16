Given /^an RTSP server at "([^"]*)" and port (\d+)$/ do |ip_address, port|
  @rtp_port = port
  @client = RTSPClient.new :host => ip_address
  @client.setup :port => @rtp_port.to_i
end

When /^I play a stream from that server$/ do
  @play_result = lambda { @client.play }
end

Then /^I should not receive any errors$/ do
  @play_result.should_not raise_error
end

Then /^I should receive data on the same port$/ do
  socket = UDPSocket.new
  socket.bind("0.0.0.0", @rtp_port)

  begin
    status = Timeout::timeout(5) do
      while data = socket.recvfrom(102400)[0]
        puts "marker size:#{data.size}"
      end
    end

    data.should_not be_nil
  rescue Timeout::Error
    raise "Data not recieved within timeout"
  ensure
    socket.close
  end
end
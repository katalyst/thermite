# frozen_string_literal: true

Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.fullscreen  :self
  policy.geolocation :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.payment     :none
  policy.usb         :none
end

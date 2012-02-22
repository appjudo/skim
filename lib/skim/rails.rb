module Skim
  if ::Rails.version < "3.1"
    class Railtie < ::Rails::Railtie; end
  else
    class RailsEngine < ::Rails::Engine; end
  end
end

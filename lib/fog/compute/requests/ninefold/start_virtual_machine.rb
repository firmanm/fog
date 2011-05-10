module Fog
  module Ninefold
    class Compute
      class Real

        def start_virtual_machine(options = {})
          request('startVirtualMachine', options, :expects => [200],
                  :response_prefix => 'startvirtualmachineresponse', :response_type => Hash)
        end

      end

      class Mock

        def start_virtual_machine(*args)
          Fog::Mock.not_implemented
        end

      end

    end
  end
end

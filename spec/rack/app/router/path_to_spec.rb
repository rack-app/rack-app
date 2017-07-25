require 'spec_helper'
RSpec.describe 'Rack::App.router' do
  rack_app do
    mount OthExampleRackApp, to: '/oth'
  end

  describe '#path_to' do
    subject(:after_path_lookup) { rack_app.router.path_to(mounted_class, mounted_class_original_path) }

    context 'when the requested mounted app not even in the router' do
      let(:mounted_class) { ExampleRackApp }
      let(:mounted_class_original_path) { '/' }

      it { expect { after_path_lookup }.to raise_error Rack::App::Router::Error::AppIsNotMountedInTheRouter }
      it { expect { after_path_lookup }.to raise_error 'ExampleRackApp is not registered in the router' }
    end

    context 'when the mounted app is already registered in the router' do
      let(:mounted_class) { OthExampleRackApp }

      context 'and the path we look from the registered app is not present' do
        let(:mounted_class_original_path) { '/not/registered/path/in/OthExampleRackApp' }

        it { expect { after_path_lookup }.to raise_error Rack::App::Router::Error::MountedAppDoesNotHaveThisPath }
        it { expect { after_path_lookup }.to raise_error 'missing path reference' }
      end

      context 'and the path we look from the registered app is actually there' do
        let(:mounted_class_original_path) { '/' }

        it { is_expected.to eq '/oth' }
      end
    end
  end
end

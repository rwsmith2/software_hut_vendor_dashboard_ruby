require 'rails_helper'

RSpec.describe "Completedtasks", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/completedtasks/index"
      expect(response).to have_http_status(302)
    end
  end

end

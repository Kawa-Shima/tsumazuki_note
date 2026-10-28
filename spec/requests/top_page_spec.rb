require 'rails_helper'

RSpec.describe "TOPページ", type: :request do
    it "正常に表示され、アプリ名が表示される" do
        get "/"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("つまずきノート")
    end
end

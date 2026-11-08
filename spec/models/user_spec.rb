require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "正しいメールアドレスとパスワードを保存できる" do
     user = FactoryBot.build(:user)

     expect(user.save).to be true
   end

    it "メールアドレスが空の場合、保存できない" do
      user = FactoryBot.build(:user, email: "")

      expect(user.save).to be false
    end

    it "メールアドレスの形式が不正なら保存できない" do
      user = FactoryBot.build(:user, email: "invalid_email")

      expect(user.save).to be false
    end

    it "メールアドレスが重複している場合、保存できない" do
      user1 = FactoryBot.create(:user, email: "example@example.com")
      user2 = FactoryBot.build(:user, email: "example@example.com")

      expect(user2.save).to be false
    end

    it "パスワードが空なら保存できない" do
      user = FactoryBot.build(:user, password: "")

      expect(user.save).to be false
    end

    it "パスワードが6文字未満なら保存できない" do
      user = FactoryBot.build(:user, password: "12345")

      expect(user.save).to be false
    end
  end
end

require 'rails_helper'
require_relative '../fabricators/user_fabricator'

describe BetterAnonymous::ActionsController do
  before do
    Jobs.run_immediately!
    SiteSetting.allow_anonymous_posting = true
  end

  let(:user) { Fabricate(:user) }
  # let(:anon1) { Fabricate(:better_anon) }
  # let(:anon2) { Fabricate(:better_anon) }

  # def update_anon_user(anon, master, active)
  #   au = AnonymousUser.where(user_id: anon.id)
  #   if au.count > 0
  #     au.update_all(master_user_id: master.id)
  #     au
  #   else
  #     AnonymousUser.create!(user_id: anon.id, master_user_id: master.id, active: active)
  #   end
  # end

  it 'can list' do
    sign_in(user)

    post "/better-anonymous/new.json", params: {}
    expect(response.status).to eq(200)
    post "/better-anonymous/new.json", params: {}
    expect(response.status).to eq(200)

    get "/better-anonymous/list.json"
    anons = response.parsed_body["actions"]
    puts(anons)
    puts(anons.to_json)
    expect(anons.length).to eq(2)
    expect(response.status).to eq(200)
  end

  it 'can create a new anon account' do
    u2 = Fabricate(:user)
    sign_in(u2)

    post "/better-anonymous/new.json", params: {}
    expect(response.status).to eq(200)
    # puts(response.parsed_body)
    fst_anon_id = response.parsed_body["basic_user"]["id"]
    expect(User.find(fst_anon_id).post_count).to eq(0)

    get "/better-anonymous/list.json"
    expect(response.status).to eq(200)
    # puts("list after creation: #{response.body}")
    expect(response.parsed_body.length).to eq(1)

    post "/better-anonymous/new.json", params: {}
    expect(response.status).to eq(200)
    snd_anon_id = response.parsed_body["basic_user"]["id"]
    # puts(response.parsed_body)
    get "/better-anonymous/list.json"
    # puts("list after creation2: #{response.body}")
    expect(response.parsed_body["actions"].length).to eq(2)

    expect(User.find(fst_anon_id).post_count).to eq(0)

    expect(AnonymousUser.where(user_id: fst_anon_id).first.active).to eq(false)
    expect(AnonymousUser.where(user_id: snd_anon_id).first.active).to eq(true)
    expect(u2.shadow_user.id).to eq(snd_anon_id)


    post "/better-anonymous/new.json", params: {}
    expect(response.status).to eq(200)
    u2.reload
    expect(AnonymousUser.where(user_id: snd_anon_id).first.active).to eq(false)
    expect(u2.shadow_user.id).not_to eq(snd_anon_id)
  end

  it 'can change anon accounts' do
    sign_in(user)
    anon_ids = []
    post "/better-anonymous/new.json", params: {}
    anon_ids.push(response.parsed_body["basic_user"]["id"])
    post "/better-anonymous/new.json", params: {}
    anon_ids.push(response.parsed_body["basic_user"]["id"])
    post "/better-anonymous/new.json", params: {}
    anon_ids.push(response.parsed_body["basic_user"]["id"])

    expect(AnonymousUser.where(user_id: anon_ids[0]).first.active).to eq(false)
    expect(AnonymousUser.where(user_id: anon_ids[1]).first.active).to eq(false)
    expect(AnonymousUser.where(user_id: anon_ids[2]).first.active).to eq(true)

    post "/better-anonymous/set_active.json", params: {shadow_user_id: anon_ids[0]}
    expect(response.status).to eq(200)

    expect(AnonymousUser.where(user_id: anon_ids[0]).first.active).to eq(true)
    expect(AnonymousUser.where(user_id: anon_ids[1]).first.active).to eq(false)
    expect(AnonymousUser.where(user_id: anon_ids[2]).first.active).to eq(false)
    expect(session[:current_user_id]).to eq(user.id)

    post "/u/toggle-anon.json"
    expect(response.status).to eq(200)
    expect(session[:current_user_id]).to eq(anon_ids[0])

    # try making request from anon account
    post "/better-anonymous/set_active.json", params: {shadow_user_id: anon_ids[1]}
    expect(response.status).to eq(200)

    expect(AnonymousUser.where(user_id: anon_ids[0]).first.active).to eq(false)
    expect(AnonymousUser.where(user_id: anon_ids[1]).first.active).to eq(true)
    expect(AnonymousUser.where(user_id: anon_ids[2]).first.active).to eq(false)

    expect(session[:current_user_id]).to eq(anon_ids[1])
    post "/u/toggle-anon.json"
    expect(session[:current_user_id]).to eq(user.id)

    # simulate activating an old anon account
    anon_1_user = User.find(anon_ids[1])
    anon_1_user.last_posted_at = SiteSetting.anonymous_account_duration_minutes.minutes.ago - 1
    anon_1_user.save!
    stat = anon_1_user.user_stat
    stat.post_count += 1
    stat.save!

    post "/better-anonymous/set_active.json", params: {shadow_user_id: anon_ids[1]}
    post "/u/toggle-anon.json"
    expect(session[:current_user_id]).to eq(anon_ids[1])
  end

  it 'refuses to change other ppls anon accounts' do
    user1 = Fabricate(:user)
    user2 = Fabricate(:user)

    sign_in(user1)
    post "/better-anonymous/new.json", params: {}
    user1_anon_id1 = response.parsed_body["basic_user"]["id"]
    post "/better-anonymous/new.json", params: {}
    user1_anon_id2 = response.parsed_body["basic_user"]["id"]

    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id1}
    expect(response.status).to eq(200)
    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id2}
    expect(response.status).to eq(200)
    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id2}
    expect(response.status).to eq(200)

    sign_in(user2)
    post "/better-anonymous/new.json", params: {}
    post "/better-anonymous/new.json", params: {}
    user2_anon_id = response.parsed_body["basic_user"]["id"]

    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id2}
    expect(response.status).to eq(401)
  end

  it "# todo: it's possible to be an active anon user and make new anon users (so the current anon user is inactive and the new anon user is active, but you're logged in to the first anon user still)"

  it "creates anon users properly when you're anon (might need to be acceptance test)"

end

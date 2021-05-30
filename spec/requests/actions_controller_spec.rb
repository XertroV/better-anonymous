require 'rails_helper'
require_relative '../fabricators/user_fabricator'

describe BetterAnonymous::ActionsController do
  before do
    Jobs.run_immediately!
    SiteSetting.allow_anonymous_posting = true
  end

  let(:user) { Fabricate(:user) }
  let(:anon1) { Fabricate(:better_anon) }
  let(:anon2) { Fabricate(:better_anon) }
  
  def update_anon_user(anon, master, active)
    au = AnonymousUser.where(user_id: anon.id)
    if au.count > 0
      au.update_all(master_user_id: master.id)
      au
    else
      AnonymousUser.create!(user_id: anon.id, master_user_id: master.id, active: active)
    end
  end

  it 'can list' do
    a = update_anon_user(anon1, user, false)
    # puts("created 1; #{a.as_json}")
    update_anon_user(anon2, user, true)
    # puts('created 2')

    sign_in(user)
    get "/better-anonymous/list.json"
    anons = response.parsed_body
    # puts(anons)
    expect(anons.length).to eq(2)
    expect(response.status).to eq(200)
  end

  it 'can create a new anon account' do
    u2 = Fabricate(:user)
    sign_in(u2)

    get "/better-anonymous/new.json"
    expect(response.status).to eq(200)
    # puts(response.parsed_body)
    fst_anon_id = response.parsed_body["basic_user"]["id"]
    expect(User.find(fst_anon_id).post_count).to eq(0)

    get "/better-anonymous/list.json"
    expect(response.status).to eq(200)
    # puts("list after creation: #{response.body}")
    expect(response.parsed_body.length).to eq(1)

    get "/better-anonymous/new.json"
    expect(response.status).to eq(200)
    snd_anon_id = response.parsed_body["basic_user"]["id"]
    # puts(response.parsed_body)
    get "/better-anonymous/list.json"
    # puts("list after creation2: #{response.body}")
    expect(response.parsed_body.length).to eq(2)

    expect(User.find(fst_anon_id).post_count).to eq(0)

    expect(AnonymousUser.where(user_id: fst_anon_id).first.active).to eq(false)
    expect(AnonymousUser.where(user_id: snd_anon_id).first.active).to eq(true)
    expect(u2.shadow_user.id).to eq(snd_anon_id)


    get "/better-anonymous/new.json"
    expect(response.status).to eq(200)
    u2.reload
    expect(AnonymousUser.where(user_id: snd_anon_id).first.active).to eq(false)
    expect(u2.shadow_user.id).not_to eq(snd_anon_id)
  end

  it 'can change anon accounts' do
    sign_in(user)
    anon_ids = []
    get "/better-anonymous/new.json"
    anon_ids.push(response.parsed_body["basic_user"]["id"])
    get "/better-anonymous/new.json"
    anon_ids.push(response.parsed_body["basic_user"]["id"])
    get "/better-anonymous/new.json"
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
  end

  it 'refuses to change other ppls anon accounts' do
    user1 = Fabricate(:user)
    user2 = Fabricate(:user)

    sign_in(user1)
    get "/better-anonymous/new.json"
    user1_anon_id1 = response.parsed_body["basic_user"]["id"]
    get "/better-anonymous/new.json"
    user1_anon_id2 = response.parsed_body["basic_user"]["id"]

    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id1}
    expect(response.status).to eq(200)
    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id2}
    expect(response.status).to eq(200)
    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id2}
    expect(response.status).to eq(200)

    sign_in(user2)
    get "/better-anonymous/new.json"
    get "/better-anonymous/new.json"
    user2_anon_id = response.parsed_body["basic_user"]["id"]

    post "/better-anonymous/set_active.json", params: {shadow_user_id: user1_anon_id2}
    expect(response.status).to eq(401)
  end

end

# このrequireで、Capybaraなどの、Feature Specに必要な機能を使用可能な状態にしています
require 'rails_helper'
FactoryBot.define do
  factory :task do
    id{'2'}
    title { 'test02' }
    details { 'test02_details' }
    deadline { '2019/09/01' }
    priority { 'low' }
    status { '完了' }
    created_at {'2019/10/05 00:00:00'}
  end
  factory :second_task, class: Task do
    id{'3'}
    title { 'test03' }
    details { 'test03_details' }
    deadline { '2019/09/03' }
    priority { 'middle' }
    status { '未着手' }
    created_at {'2019/10/06 00:00:00'}
  end
  factory :third_task, class: Task do
    id{'4'}
    title { 'test04' }
    details { 'test04_details' }
    deadline { '2019/09/04' }
    priority { 'high' }
    status { '未着手' }
    created_at {'2019/10/07 00:00:00'}
  end

  factory :task_another, class: Task do
    id{'5'}
    title { 'test05' }
    details { 'test05_details' }
    deadline { '2019/09/02' }
    priority { 'middle' }
    status { '完了' }
    created_at {'2019/10/08 00:00:00'}
  end
  factory :quattro_task, class: Task do
    id{'6'}
    title { 'test06' }
    details { 'test06_details' }
    deadline { '2019/09/01' }
    priority { 'high' }
    status { '着手' }
    created_at {'2019/10/09 00:00:00'}
  end
  factory :zero_task, class: Task do
    id{'7'}
    title { 'test00' }
    details { 'test00_details' }
    deadline { '2019/08/30' }
    priority { 'low' }
    status { '着手' }
    created_at {'2019/7/01 00:00:00'}
  end
end
# このRSpec.featureの右側に、「タスク管理機能」のように、テスト項目の名称を書きます（do ~ endでグループ化されています）
RSpec.feature "タスク管理機能", type: :feature do
  background do
    FactoryBot.create(:task)
    FactoryBot.create(:zero_task)
    FactoryBot.create(:second_task)
    FactoryBot.create(:third_task)
    FactoryBot.create(:task_another)
    FactoryBot.create(:quattro_task)
  end
  scenario "タスク一覧のテスト" do
      # tasks_pathにvisitする（タスク一覧ページに遷移する）
      visit tasks_path

      # visitした（到着した）expect(page)に（タスク一覧ページに）「testtesttest」「samplesample」という文字列が
      # have_contentされているか？（含まれているか？）ということをexpectする（確認・期待する）テストを書いている
      expect(page).to have_content 'test02'
      expect(page).to have_content 'test03'
  end

  scenario "タスク作成のテスト" do
    visit new_task_path

    fill_in 'task[title]', with: 'test01'
    fill_in 'task[details]', with: 'test01_詳細'
    fill_in 'task[deadline]', with: '2019/08/01'
    select '高', from: 'task[priority]'
    select '未着手', from: 'task[status]'
    click_on '登録する'
    expect(page).to have_content 'test01'
  end

  scenario "タスク詳細のテスト" do
    visit task_path(5)
    expect(page).to have_content 'test05'
  end

  scenario "タスクが作成日時の降順に並んでいるかのテスト" do
    visit tasks_path
    tasks = page.all('.title_content')
    expect(tasks[0]).to have_content 'test06'
    expect(tasks[1]).to have_content 'test05'
    expect(tasks[2]).to have_content 'test04'
    expect(tasks[3]).to have_content 'test03'
    expect(tasks[4]).to have_content 'test02'
  end

  scenario "タスクが終了期限の降順に並んでいるかのテスト" do
    visit tasks_path
    click_on '終了期限でソートする'
    tasks = page.all('.deadline')
    expect(tasks[0]).to have_content '9月04日'
    expect(tasks[1]).to have_content '9月03日'
    expect(tasks[2]).to have_content '9月02日'
    expect(tasks[3]).to have_content '9月01日'
  end

  scenario "タスクのステータス検索ができるかのテスト(未着手のみの表示)" do
    visit tasks_path
    # fill_in 'Status search', with: '未着手'
    select '未着手', from: 'task[status]'
    click_on '検索する'
    tasks = page.all('.title_content')
    expect(tasks[0]).to have_content 'test04'
    expect(tasks[1]).to have_content 'test03'
    expect(tasks[2]).to have_content ''
    expect(tasks[3]).to have_content ''
  end
  scenario "タスクのタイトル検索ができるかのテスト" do
    visit tasks_path
    fill_in 'task[title]', with: 'test05'
    click_on '検索する'
    tasks = page.all('.title_content')
    expect(tasks.length).to eq 1
    expect(tasks[0]).to have_content 'test05'
  end

  scenario "タスクのステータス検索ができるかのテスト" do
    visit tasks_path
    select '未着手', from: 'task[status]'
    click_on '検索する'
    tasks = page.all('.title_content')
    expect(tasks.length).to eq 2
    expect(tasks[0]).to have_content 'test04'
    expect(tasks[1]).to have_content 'test03'
  end

  scenario "タスクのタイトルとステータスの同時検索ができるかのテスト" do
    visit tasks_path
    fill_in 'task[title]', with: 'test0'
    select '完了', from: 'task[status]'
    click_on '検索する'
    tasks = page.all('.title_content')
    expect(tasks.length).to eq 2
    expect(tasks[0]).to have_content 'test05'
    expect(tasks[1]).to have_content 'test02'
  end

  scenario "タスクが優先順位に並んでいるかのテスト" do
    visit tasks_path
    click_on '優先順位でソートする'
    tasks = page.all('.priority')
    expect(tasks[0]).to have_content '高'
    expect(tasks[1]).to have_content '高'
    expect(tasks[2]).to have_content '中'
    expect(tasks[3]).to have_content '中'
    expect(tasks[4]).to have_content '低'
  end

  scenario "ページネーションが適用できているかテスト" do
    visit tasks_path
    click_on '2'
    tasks = page.all('.title_content')
    expect(tasks.length).to eq 1
    expect(tasks[0]).to have_content 'test00'
  end
  # save_and_open_page
end

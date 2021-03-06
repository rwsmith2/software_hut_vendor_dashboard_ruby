require 'rails_helper'

describe 'Admin given task management' do

  specify 'I can edit a given task', :js => true do
    make_test_data

    visit '/users/sign_in'
    fill_in 'Email', with: 'domin@gmail.com'
    fill_in 'Password', with: 'password'
    click_button 'Log in'
    click_link 'Given Tasks'

    click_link 'Edit'
    wait_for_ajax

    fill_in 'given_task_repeatable', with: '10'
    # click_button 'Assign Tasks'
    # wait_for_ajax

    # click_link 'Given Tasks'
    # expect(page).to have_content 'Repeats every 10 days'
  end

  specify 'I can delete a given task', :js => true do
    make_test_data

    visit '/users/sign_in'
    fill_in 'Email', with: 'domin@gmail.com'
    fill_in 'Password', with: 'password'
    click_button 'Log in'
    click_link 'Given Tasks'
    
    accept_alert do
      click_link 'Destroy'
    end
    wait_for_ajax

    expect(page).to have_no_content 'Example Task 1'
    expect(page).to have_content 'Example Task 2'
  end

  def make_test_data
    # admin user
    user_admin = User.create(email: "domin@gmail.com", password: "password", user_name: "domin@gmail.com", is_admin: true)
    Admin.create(user_id: user_admin.user_id)

    # vendor user
    user_vendor = User.create(email: "mmq1@gmail.com", password: "password", user_name: "mmq1@gmail.com", is_admin: false)
    vendor = Vendor.create(user_id: user_vendor.user_id, company_name: "MM Quality", company_number: "1455", validated: true)
    address = Address.create(vendor_id: vendor.vendor_id, city_town: "Sheffield", country: "Sheffield", house_name: "67", postcode: "S1 CBQ")
    
    # task
    task1 = Task.create(task_title: "Example Task 1", task_description: "A nice Task", estimation: "1")
    task2 = Task.create(task_title: "Example Task 2", task_description: "A good Task", estimation: "1")
    # given_task1 = GivenTask.create(set_date: "2021-04-25", due_date: "2021-05-01", priority: "2", repeatable: "7", task_id: task1.task_id)
    # given_task2 = GivenTask.create(set_date: "2021-04-25", due_date: "2021-05-01", priority: "2", repeatable: "7", task_id: task2.task_id)
    given_task1 = GivenTask.create(set_date: "2021-04-25", due_date: "2021-05-01", priority: "2", repeatable: "0", task_id: task1.task_id)
    given_task2 = GivenTask.create(set_date: "2021-04-25", due_date: "2021-05-01", priority: "2", repeatable: "0", task_id: task2.task_id)

    # assessment
    assessment = Assessment.new(assessment_title: "Assessment questions")
    assessment.save(:validate => false)
    AssessmentLinker.create(task_id: task1.task_id, assessment_id: assessment.assessment_id)
    AssessmentLinker.create(task_id: task2.task_id, assessment_id: assessment.assessment_id)
    
    # assign
    assignment = Assignment.create(vendor_id: vendor.vendor_id, given_task_id: given_task1.given_task_id, complete_by: "2021-05-01")
    assignment = Assignment.create(vendor_id: vendor.vendor_id, given_task_id: given_task2.given_task_id, complete_by: "2021-05-01")
  end

end

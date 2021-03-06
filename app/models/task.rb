class Task < ApplicationRecord
  validates :title, presence: true
  validates :details, presence: true
  validates :deadline, presence: true
  validates :priority, presence: true
  enum priority:{low: 0,middle: 1,high: 2}
  validates :status, presence: true
  belongs_to :user
  has_many :tags,dependent: :destroy
  has_many :labels, through: :tags
  
  scope :create_time_desc, -> {order(created_at: :desc)}
  scope :deadline_time_desc, -> {order(deadline: :desc)}
  scope :priority_status_desc, -> {order(priority: :desc)}
  scope :search_title, -> (title){where("title LIKE ?", "%#{ title }%")}
  scope :search_status, -> (status){where("status LIKE ?", "#{ status }%")}
  scope :search_label, -> (label){where(id:Tag.where(label_id: label ).select(:task_id))}

  def self.list(parameter)
    if parameter[:sort_expired]
      deadline_time_desc
    elsif parameter[:sort_priority]
      priority_status_desc
    elsif parameter[:task].present?
      if  parameter[:task][:title].present? and parameter[:task][:status].present? and parameter[:task][:label].present?
        search_title(parameter[:task][:title]).search_status(parameter[:task][:status]).search_label(parameter[:task][:label]).create_time_desc
      elsif parameter[:task][:title].present? and parameter[:task][:status].present?
        search_title(parameter[:task][:title]).search_status(parameter[:task][:status]).create_time_desc
      elsif parameter[:task][:title].present? and parameter[:task][:label].present?
        search_title(parameter[:task][:title]).search_label(parameter[:task][:label]).create_time_desc
      elsif parameter[:task][:status].present? and parameter[:task][:label].present?
        search_status(parameter[:task][:status]).search_label(parameter[:task][:label]).create_time_desc
      elsif parameter[:task][:title].present?
        search_title(parameter[:task][:title]).create_time_desc
      elsif parameter[:task][:status].present?
        search_status(parameter[:task][:status]).create_time_desc
      elsif parameter[:task][:label].present?
        search_label(parameter[:task][:label]).create_time_desc
      end
    else
      create_time_desc
    end
  end

end

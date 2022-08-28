class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  validates :event, presence: true
  # Проверки user_name и user_email выполняются,
  # только если user не задан
  # То есть для анонимных пользователей
  validates :user_name, presence: true, unless: -> { user.present? }
  validates :user_email, presence: true, format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/, unless: -> { user.present? }

  validates :user, uniqueness: { scope: :event_id }, if: -> { user.present? }
  validates :user_email, uniqueness: { scope: :event_id }, unless: -> { user.present? }
  validate :sub_not_owner
  validate :sub_is_not_already_existing, if: -> { user.nil? }

  # Если есть юзер, выдаем его имя,
  # если нет – дергаем исходный метод
  def user_name
    if user.present?
      user.name
    else
      super
    end
  end

  # Если есть юзер, выдаем его email,
  # если нет – дергаем исходный метод
  def user_email
    if user.present?
      user.email
    else
      super
    end
  end

  def sub_not_owner
    if event.user == user
      errors.add(:user, I18n.t("subscription.errors.self-owner"))
    end
  end

  def sub_is_not_already_existing
    if User.where(email: user_email).present?
      errors.add(:user_email, I18n.t("subscription.errors.existing-email"))
    end
  end

end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  # omniauthのコールバック時に呼ばれるメソッド
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = ''
      user.year = 0
    end
  end

  with_options presence: true do
    validates :year
  end

  has_many :learnings, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :journals, dependent: :destroy

  # 追加メソッド
  # deviseにおいてパスワード入力なしでupdateを行う
  def update_without_password(params)
    params.delete(:password)
    params.delete(:password_confirmation)

    update_attributes(params)
  end

  # 年度データが存在すればtrueを返す
  def has_year?
    self.year != 0 #初回データ作成後は必ず年度データがyearに格納されている前提（前提条件が変わった場合DB検索を検討）
  end

  # ユーザが持つ全ての年度データを返す
  def has_years
    accounts = Account.where(user_id: self.id)
    year = []
    accounts.each do |account|
      year.push(account.year) unless year.include?(account.year)
    end
    return year
  end

  # ユーザの持つ年度、入力月から月初日を返す
  def start_date(start_month)
    Time.new(self.year, start_month, 1).beginning_of_month
  end

  # ユーザの持つ年度、入力月から月末日を返す
  def end_date(end_month)
    Time.new(self.year, end_month, 1).end_of_month
  end

  # ユーザの持つ年度、開始月、終了月から期間を返す
  def start_date_to_end_date(start_month, end_month)
    self.start_date(start_month)..self.end_date(end_month)
  end

  # 勘定科目の初期データ作成
  def accounts_setting(year)
    # 年度データを更新
    self.update(year: year)

    # 初期勘定科目リスト
    accounts = [
      [101, '現金', '現預金'],
      [111, '普通預金1', '現預金'],
      [112, '普通預金2', '現預金'],
      [113, '普通預金3', '現預金'],
      [170, '未入金給与', '他流動資産'],
      [171, '保険積立金', '他流動資産'],
      [172, '他流動資産1', '他流動資産'],
      [173, '他流動資産2', '他流動資産'],
      [174, '他流動資産3', '他流動資産'],
      [201, '家', '固定資産'],
      [202, '車', '固定資産'],
      [203, '固定資産1', '固定資産'],
      [204, '固定資産2', '固定資産'],
      [205, '固定資産3', '固定資産'],
      [301, 'カード1', 'カード'],
      [302, 'カード2', 'カード'],
      [303, 'カード3', 'カード'],
      [311, '他流動負債1', '他流動負債'],
      [312, '他流動負債2', '他流動負債'],
      [313, '他流動負債3', '他流動負債'],
      [340, 'ローン', '固定負債'],
      [341, '奨学金', '固定負債'],
      [342, '他固定負債1', '固定負債'],
      [343, '他固定負債2', '固定負債'],
      [344, '他固定負債3', '固定負債'],
      [410, '基本給', '収入'],
      [411, '残業代', '収入'],
      [412, '手当', '収入'],
      [413, '賞与', '収入'],
      [414, '他収入1', '収入'],
      [415, '他収入2', '収入'],
      [416, '他収入3', '収入'],
      [511, '社会保険料', '原価'],
      [512, '源泉所得税', '原価'],
      [513, '住民税', '原価'],
      [514, '他控除1', '原価'],
      [515, '他控除2', '原価'],
      [516, '他控除3', '原価'],
      [601, '食費', '販管費'],
      [602, '交通費', '販管費'],
      [603, '通信費', '販管費'],
      [604, '接待交際費', '販管費'],
      [605, '地代家賃', '販管費'],
      [606, '保険料', '販管費'],
      [607, '消耗品費', '販管費'],
      [608, '娯楽費', '販管費'],
      [609, '研修費', '販管費'],
      [610, '被服費', '販管費'],
      [611, '水道光熱費', '販管費'],
      [612, '車両費', '販管費'],
      [613, '税金等', '販管費'],
      [614, '医療費', '販管費'],
      [615, '減価償却費', '販管費'],
      [616, '雑費', '販管費'],
      [617, '他販管費1', '販管費'],
      [618, '他販管費2', '販管費'],
      [619, '他販管費3', '販管費'],
      [701, 'ポイント', '営業外収入'],
      [702, '受取利息', '営業外収入'],
      [703, '他雑収入1', '営業外収入'],
      [704, '他雑収入2', '営業外収入'],
      [705, '他雑収入3', '営業外収入'],
      [801, '支払利息', '営業外費用'],
      [802, '使徒不明金', '営業外費用'],
      [803, '他雑支出1', '営業外費用'],
      [804, '他雑支出2', '営業外費用'],
      [805, '他雑支出3', '営業外費用'],
    ]

    accounts.each do |account|
      Account.create(
        user_id:       self.id,
        year:          year,
        code:          account[0],
        name:          account[1],
        total_account: account[2]
      )
    end
  end

  # 学習済みであればtrueを返す
  def learned?(content)
    Learning.find_by(user_id: self.id, content_id: content.id).present?
  end

end

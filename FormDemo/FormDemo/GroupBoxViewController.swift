import UIKit

class GroupBoxViewController: UIViewController {

  var flag = false
  let groupBox = UIView()
  let groupBoxLabel = UILabel()
  let toggle = UISwitch()
  let textField = UITextField()
    let textView = UITextView()
    let extraTextView = UITextView()
  var groupBoxConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    setupGroupBox()
      setupExtraTextView()
    // 키보드 알림 등록
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 키보드 알림 해제
    NotificationCenter.default.removeObserver(self)
  }

  func setupGroupBox() {
    groupBox.layer.borderWidth = 1
    groupBox.layer.borderColor = UIColor.lightGray.cgColor
    groupBox.layer.cornerRadius = 8
    groupBox.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(groupBox)

    groupBoxLabel.text = "그룹 박스"
    groupBoxLabel.font = .systemFont(ofSize: 20)
    groupBoxLabel.translatesAutoresizingMaskIntoConstraints = false
    groupBox.addSubview(groupBoxLabel)

    toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    toggle.translatesAutoresizingMaskIntoConstraints = false
    groupBox.addSubview(toggle)

    textField.borderStyle = .roundedRect
    textField.placeholder = "텍스트 필드"
      // 엔터키
    // 이벤트 처리방식 변경 실습으로 주석 처리
//    textField.delegate = self
    textField.translatesAutoresizingMaskIntoConstraints = false
    groupBox.addSubview(textField)
      
      textView.text = "텍스트 뷰"
      textView.delegate = self
      textView.backgroundColor = .lightGray
      textView.isScrollEnabled = false
      textView.translatesAutoresizingMaskIntoConstraints = false
      groupBox.addSubview(textView)

    groupBoxConstraint = groupBox.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)

    NSLayoutConstraint.activate([
      groupBoxConstraint,
      groupBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      groupBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

      groupBoxLabel.topAnchor.constraint(equalTo: groupBox.topAnchor, constant: 20),
      groupBoxLabel.leadingAnchor.constraint(equalTo: groupBox.leadingAnchor, constant: 10),

      toggle.topAnchor.constraint(equalTo: groupBoxLabel.bottomAnchor, constant: 10),
      toggle.leadingAnchor.constraint(equalTo: groupBox.leadingAnchor, constant: 10),

      textField.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: 10),
      textField.leadingAnchor.constraint(equalTo: groupBox.leadingAnchor, constant: 10),
      textField.trailingAnchor.constraint(equalTo: groupBox.trailingAnchor, constant: -10),
      
      textView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
      textView.leadingAnchor.constraint(equalTo: groupBox.leadingAnchor, constant: 10),
      textView.trailingAnchor.constraint(equalTo: groupBox.trailingAnchor, constant: -10),
      textView.bottomAnchor.constraint(equalTo: groupBox.bottomAnchor, constant: -10)

    ])
  }
    func setupExtraTextView() {
            extraTextView.text = "텍스트 뷰 (그룹 박스 바깥)"
            extraTextView.delegate = self
            extraTextView.isScrollEnabled = false
            extraTextView.backgroundColor = .yellow
            extraTextView.font = UIFont.systemFont(ofSize: 16)
            extraTextView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(extraTextView)

            NSLayoutConstraint.activate([
                extraTextView.topAnchor.constraint(equalTo: groupBox.bottomAnchor, constant: 20),
                extraTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                extraTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                extraTextView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        }

  func moveGroupBox(forEditing: Bool) {
    groupBoxConstraint.constant = forEditing ? -100 : 100
  }

  @objc func toggleChanged() {
    flag = toggle.isOn
    print("flag: \(flag)")
    // 텍스트 필드 편집 종료
    textField.resignFirstResponder()
      textView.resignFirstResponder()
      extraTextView.resignFirstResponder()
  }

  @objc func keyboardWillShow(_ notification: Notification) {
    print("키보드 표시")
    moveGroupBox(forEditing: true)
  }

  @objc func keyboardWillHide(_ notification: Notification) {
    print("키보드 숨김")
    moveGroupBox(forEditing: false)
  }
}

extension GroupBoxViewController: UITextFieldDelegate {
  // 편집 가능 여부 결정
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return flag
  }

  // 텍스트 필드 편집 시작
  func textFieldDidBeginEditing(_ textField: UITextField) {
    print("편집 시작")
    moveGroupBox(forEditing: true)
  }

  // 텍스트 필드 문자 입력
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    let currentText = textField.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }
    let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

    print("실제 입력 값: \(string)")
    print("현재 텍스트 필드 값: \(currentText)")
    print("최종 업데이트 텍스트: \(updatedText)")

    return true
  }

  // 필드 편집 종료
  func textFieldDidEndEditing(_ textField: UITextField) {
    print("편집 종료")
    moveGroupBox(forEditing: false)
  }
}



extension GroupBoxViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }

        // 그룹 박스 크기 조절 (textView의 bottomAnchor를 사용하고 있어서 자동으로 늘어남)
        view.layoutIfNeeded()
    }
}

#Preview {
  GroupBoxViewController()
}

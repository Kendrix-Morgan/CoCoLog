//
//  AccountView.swift
//  COCOLOG_Sample
//
//  Created by cmStudent on 2025/08/03.
//
import SwiftUI
import PhotosUI

struct AccountView: View {
    @State private var isEditing = false
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false

    let nameKey = "userName"
    let phoneKey = "userPhone"
    let emailKey = "userEmail"
    let imageFileName = "profile.jpg"

    var body: some View {
        ZStack {
            Color(hex: "FAF6EB").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Text("アカウント")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "914D26"))
                        .padding(.top)

                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "914D26"), lineWidth: 3))
                                .shadow(radius: 5)
                        } else {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $profileImage)
                            .onDisappear {
                                saveImage()
                            }
                    }

                    VStack(spacing: 16) {
                        FieldView(title: "氏名", value: $name, isEditing: isEditing)
                        FieldView(title: "電話番号", value: $phoneNumber, isEditing: isEditing)
                        FieldView(title: "メール", value: $email, isEditing: isEditing)
                    }
                    .padding()
                    .background(.white.opacity(0.3))
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)

                    Button(action: {
                        if isEditing {
                            saveData()
                        }
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "保存" : "編集")
                            .font(.headline)
                            .frame(width: 140, height: 44)
                            .background(Color(hex: "914D26"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            loadData()
        }
    }

    // MARK: - 保存
    func saveData() {
        UserDefaults.standard.set(name, forKey: nameKey)
        UserDefaults.standard.set(phoneNumber, forKey: phoneKey)
        UserDefaults.standard.set(email, forKey: emailKey)
    }

    func saveImage() {
        guard let data = profileImage?.jpegData(compressionQuality: 0.8) else { return }
        let url = getDocumentsDirectory().appendingPathComponent(imageFileName)
        try? data.write(to: url)
    }

    // MARK: - 読み込み
    func loadData() {
        name = UserDefaults.standard.string(forKey: nameKey) ?? ""
        phoneNumber = UserDefaults.standard.string(forKey: phoneKey) ?? ""
        email = UserDefaults.standard.string(forKey: emailKey) ?? ""

        let url = getDocumentsDirectory().appendingPathComponent(imageFileName)
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            profileImage = image
        }
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// サブビュー
struct FieldView: View {
    var title: String
    @Binding var value: String
    var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(hex: "914D26"))

            if isEditing {
                TextField("入力してください", text: $value)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "914D26"), lineWidth: 1)
                    )
            } else {
                Text(value.isEmpty ? "未入力" : value)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "914D26").opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

// プレビュー
#Preview {
    AccountView()
}

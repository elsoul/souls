module FireStore
  def self.log(title: "error", message: "type error!")
    Time.zone = "Asia/Tokyo"
    time = Time.zone.now.strftime("%F-%H-%M-%S")
    firestore = Google::Cloud::Firestore.new(project_id: ENV["SOULS_GCP_PROJECT_ID"])
    doc_ref = firestore.doc("Log/#{time}")
    doc_ref.set({ title: title, message: message, created_at: time })
  end
end

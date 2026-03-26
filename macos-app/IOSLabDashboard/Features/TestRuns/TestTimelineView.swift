import SwiftUI

struct TestTimelineView: View {
    let jobs: [JobModel]

    var body: some View {
        GroupBox("Test Timeline") {
            List(jobs) { job in
                HStack {
                    Text(job.testTarget)
                    Spacer()
                    Text(job.status).foregroundColor(.secondary)
                }
            }
            .frame(height: 160)
        }
    }
}

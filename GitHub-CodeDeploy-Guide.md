# Use GitHub Instead of S3 with AWS CodeDeploy (via CodePipeline)

This guide shows how to deploy your Flask app to EC2 using AWS CodeDeploy with GitHub as the source. We use AWS CodePipeline + CodeStar Connections (recommended).

## Prerequisites
- CodeDeploy application and deployment group created (from Step 3).
- EC2 instance prepared (Step 2) and tagged to match the deployment group.
- Your repository contains `appspec.yml` at the repo root and the `scripts/` folder.
- IAM: Ability to create a CodeStar Connection and a CodePipeline.

## 1) Create a CodeStar Connection to GitHub
1. Open AWS Console → **Developer Tools → Connections** → **Create connection**.
2. Connection type: **GitHub**. Authentication: Install/authorize the GitHub App.
3. Name the connection (e.g., `GitHub-FlaskDemo`) and complete the handshake.
4. Once the status is **Available**, note the connection name.

## 2) Create the CodePipeline
1. **Developer Tools → CodePipeline → Create pipeline**.
2. Pipeline settings: give it a name (e.g., `FlaskDemoPipeline`). Accept the default artifact store (S3 bucket created by CodePipeline).
3. Service role: Let CodePipeline create a new role (recommended) or choose an existing role with permissions for CodeDeploy and S3.
4. **Source stage**:
   - Source provider: **GitHub (via CodeStar connection)**.
   - Connection: select the connection created above.
   - Repository: choose your repo. Branch: choose the branch to deploy from (e.g., `main`).
   - Output artifact: `SourceArtifact` (default).
   - Change detection: enable webhooks (default) so pushes to the branch trigger the pipeline.
5. **Build stage (optional)**: Skip for this simple app, or add CodeBuild if you need tests/build steps.
6. **Deploy stage**:
   - Deploy provider: **CodeDeploy**.
   - Application name: select your CodeDeploy app (e.g., `FlaskDemoApp`).
   - Deployment group: select your group (e.g., `FlaskDG`).
7. Create pipeline.

### How Artifacts Flow (Important Note)
Even though your source is GitHub, CodePipeline stores the build output as a ZIP in its own S3 artifact bucket automatically. You do not need to manage this bucket directly—CodePipeline handles it.

## Repository Layout Reminder
```
flask-codedeploy-demo/
├─ app.py
├─ requirements.txt
├─ appspec.yml
└─ scripts/
   ├─ install_dependencies.sh
   ├─ start_server.sh
   ├─ stop_server.sh
   └─ validate_service.sh
```

## Optional: Direct CodeDeploy from GitHub (If Available)
Some accounts still show a **GitHub** revision type in the CodeDeploy console. If present:
1. CodeDeploy → Deployments → **Create deployment**.
2. Revision type: **GitHub**.
3. Enter Repository (`owner/name`) and the commit ID or branch ref.
4. Authorize access to GitHub when prompted.
5. **Create deployment**.

If this option is not available, use the **CodePipeline** method above.

## IAM & Permissions Checklist
- **CodePipeline service role** needs permissions for CodeDeploy and the artifact S3 bucket.
- **CodeDeploy service role** (created in Step 3) must exist and be selected in the deployment group.
- **EC2 instance profile** must allow fetching artifacts during deployment (S3 read) and optional `AmazonSSMManagedInstanceCore`.

## Triggers & Branch Strategy
- Pushing to the selected branch triggers the pipeline automatically (via the GitHub App connection).
- Use feature branches and pull requests; merge to the deployment branch to release.

## Troubleshooting
- **Source stage fails**: verify the CodeStar connection is in **Available** state and the repo/branch exists.
- **Deploy stage fails**: check CodeDeploy deployment events and the EC2 agent log at `/var/log/aws/codedeploy-agent/codedeploy-agent.log`.
- Ensure `appspec.yml` is at the repo root and script paths match the hooks.

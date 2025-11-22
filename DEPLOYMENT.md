# Dokploy 部署指南 / Dokploy Deployment Guide

[English](#english) | [中文](#chinese)

---

## <a name="chinese"></a>中文部署指南

### 前提条件

1. 已安装并配置好 Dokploy
2. 拥有 GitHub/GitLab 仓库访问权限
3. 已准备好以下服务：
   - Groq API Key (从 [Groq Console](https://console.groq.com/keys) 获取)
   - Cloudflare R2 或其他 S3 兼容存储

### 部署步骤

#### 方式一：使用 Docker Compose (推荐)

1. **在 Dokploy 中创建新项目**
   - 登录 Dokploy 控制台
   - 创建新项目 "AI Crawler"

2. **添加 Compose 服务**
   - 选择 "Docker Compose" 部署方式
   - 连接 Git 仓库：`https://github.com/your-username/aibesttop-ai-crawler`
   - 选择分支（如 `main` 或 `master`）

3. **配置环境变量**

   在 Dokploy 环境变量设置中添加以下变量：

   ```env
   # LLM 配置 (必填)
   GROQ_API_KEY=your_groq_api_key_here
   GROQ_MODEL=llama3-70b-8192
   GROQ_MAX_TOKENS=5000

   # 对象存储配置 (必填)
   S3_ENDPOINT_URL=https://xxxxx.r2.cloudflarestorage.com
   S3_BUCKET_NAME=your_bucket_name
   S3_ACCESS_KEY_ID=your_access_key_id
   S3_SECRET_ACCESS_KEY=your_secret_access_key
   S3_CUSTOM_DOMAIN=your_custom_domain (可选)

   # API 认证 (必填)
   AUTH_SECRET=your_random_secret_key

   # 应用设置 (可选)
   PORT=8040
   ```

4. **部署应用**
   - 点击 "Deploy" 按钮
   - Dokploy 将自动构建并启动容器
   - 等待健康检查通过

5. **配置域名和 SSL**
   - 在 Dokploy 中配置自定义域名
   - 启用自动 SSL 证书

#### 方式二：使用 Dockerfile

1. **创建应用**
   - 在 Dokploy 中选择 "Dockerfile" 部署方式
   - 连接 Git 仓库

2. **配置构建设置**
   - Dockerfile 路径：`./Dockerfile`
   - 构建上下文：`.`
   - 目标端口：`8040`

3. **配置环境变量** (同方式一)

4. **部署应用**

### 验证部署

部署完成后，访问以下端点验证：

```bash
# 健康检查
curl https://your-domain.com/health

# API 信息
curl https://your-domain.com/

# 测试爬虫 API
curl -X POST https://your-domain.com/site/crawl \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_auth_secret" \
  -d '{"url": "https://tap4.ai"}'
```

### 故障排查

#### 1. 容器无法启动
- 检查环境变量是否正确配置
- 查看 Dokploy 日志获取详细错误信息
- 确保所有必需的环境变量都已设置

#### 2. 健康检查失败
- 等待更长时间（初次启动需要下载 Chromium）
- 检查端口配置是否正确
- 查看应用日志

#### 3. 爬虫功能异常
- 验证 Groq API Key 是否有效
- 检查 S3/R2 配置和权限
- 确保服务器有足够的内存（建议至少 2GB）

#### 4. 图片上传失败
- 检查 S3_ENDPOINT_URL 格式
- 验证 S3 访问密钥权限
- 确认 Bucket CORS 配置正确

### 性能优化建议

1. **资源配置**
   - CPU: 建议 2 核以上
   - 内存: 建议 4GB 以上
   - 存储: 建议 20GB 以上

2. **并发设置**
   - 根据服务器性能调整 `--workers` 数量
   - 在 `docker-compose.yml` 中可修改 CMD 参数

3. **监控**
   - 使用 Dokploy 内置监控查看资源使用情况
   - 配置日志收集和告警

### 更新部署

1. 推送新代码到 Git 仓库
2. 在 Dokploy 中点击 "Redeploy"
3. Dokploy 将自动拉取最新代码并重新构建

---

## <a name="english"></a>English Deployment Guide

### Prerequisites

1. Dokploy installed and configured
2. GitHub/GitLab repository access
3. Required services ready:
   - Groq API Key (get from [Groq Console](https://console.groq.com/keys))
   - Cloudflare R2 or other S3-compatible storage

### Deployment Steps

#### Method 1: Using Docker Compose (Recommended)

1. **Create New Project in Dokploy**
   - Log in to Dokploy console
   - Create new project "AI Crawler"

2. **Add Compose Service**
   - Select "Docker Compose" deployment method
   - Connect Git repository: `https://github.com/your-username/aibesttop-ai-crawler`
   - Select branch (e.g., `main` or `master`)

3. **Configure Environment Variables**

   Add the following variables in Dokploy environment settings:

   ```env
   # LLM Configuration (Required)
   GROQ_API_KEY=your_groq_api_key_here
   GROQ_MODEL=llama3-70b-8192
   GROQ_MAX_TOKENS=5000

   # Object Storage Configuration (Required)
   S3_ENDPOINT_URL=https://xxxxx.r2.cloudflarestorage.com
   S3_BUCKET_NAME=your_bucket_name
   S3_ACCESS_KEY_ID=your_access_key_id
   S3_SECRET_ACCESS_KEY=your_secret_access_key
   S3_CUSTOM_DOMAIN=your_custom_domain (optional)

   # API Authentication (Required)
   AUTH_SECRET=your_random_secret_key

   # Application Settings (Optional)
   PORT=8040
   ```

4. **Deploy Application**
   - Click "Deploy" button
   - Dokploy will automatically build and start the container
   - Wait for health check to pass

5. **Configure Domain and SSL**
   - Configure custom domain in Dokploy
   - Enable automatic SSL certificates

#### Method 2: Using Dockerfile

1. **Create Application**
   - Select "Dockerfile" deployment method in Dokploy
   - Connect Git repository

2. **Configure Build Settings**
   - Dockerfile path: `./Dockerfile`
   - Build context: `.`
   - Target port: `8040`

3. **Configure Environment Variables** (same as Method 1)

4. **Deploy Application**

### Verify Deployment

After deployment, verify with these endpoints:

```bash
# Health check
curl https://your-domain.com/health

# API information
curl https://your-domain.com/

# Test crawler API
curl -X POST https://your-domain.com/site/crawl \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_auth_secret" \
  -d '{"url": "https://tap4.ai"}'
```

### Troubleshooting

#### 1. Container Won't Start
- Check if environment variables are correctly configured
- View Dokploy logs for detailed error information
- Ensure all required environment variables are set

#### 2. Health Check Fails
- Wait longer (first startup needs to download Chromium)
- Check if port configuration is correct
- Review application logs

#### 3. Crawler Not Working
- Verify Groq API Key is valid
- Check S3/R2 configuration and permissions
- Ensure server has enough memory (recommend at least 2GB)

#### 4. Image Upload Fails
- Check S3_ENDPOINT_URL format
- Verify S3 access key permissions
- Confirm Bucket CORS configuration is correct

### Performance Optimization Tips

1. **Resource Configuration**
   - CPU: Recommend 2+ cores
   - Memory: Recommend 4GB+
   - Storage: Recommend 20GB+

2. **Concurrency Settings**
   - Adjust `--workers` based on server performance
   - Modify CMD parameters in `docker-compose.yml`

3. **Monitoring**
   - Use Dokploy built-in monitoring for resource usage
   - Configure log collection and alerts

### Update Deployment

1. Push new code to Git repository
2. Click "Redeploy" in Dokploy
3. Dokploy will automatically pull latest code and rebuild

---

## Support

For issues or questions:
- GitHub Issues: [Create an issue](https://github.com/6677-ai/tap4-ai-crawler/issues)
- Twitter: [@tap4ai](https://x.com/tap4ai)

## License

This project is licensed under the MIT License.

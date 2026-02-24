# 前端界面部署指南

本指南将帮助您根据`README.md`文件搭建Web前端界面，用于查看和分析trace文件。

## 前置条件

在开始部署之前，请确保您已经：

1. 运行了评估代码生成日志数据
2. 配置了正确的数据库URL（`UTU_DB_URL`）
3. 确保评估代码和exp_analysis使用相同的`UTU_DB_URL`

## 部署步骤

### 1. 配置环境变量

确保`.env`文件中设置了正确的`UTU_DB_URL`环境变量。支持两种数据库类型：

#### SQLite配置（默认）
```bash
# 示例配置（SQLite）
UTU_DB_URL=sqlite:///test.db
```

#### PostgreSQL配置
```bash
# 示例配置（PostgreSQL）
UTU_DB_URL=postgres://username:password@localhost:5432/database_name
```

请确保PostgreSQL服务器正在运行，并且可以通过配置的连接URL访问。

### 2. 安装依赖

进入`frontend/exp_analysis`目录，安装所有npm依赖：

```bash
cd frontend/exp_analysis
npm install --legacy-peer-deps
```

### 3. 构建项目

使用Next.js构建工具构建项目：

```bash
npm run build
```

### 4. 启动服务器

启动Next.js服务器，默认端口为3000：

```bash
npm run start
```

### 5. 访问前端界面

在浏览器中访问以下URL：

```
http://localhost:3000
```

## 常见问题与解决方案

### Q1: 数据库连接失败，提示"no such table: evaluation_data"

**问题描述**：
前端服务器启动后，API端点返回空响应，服务器日志显示`SqliteError: no such table: evaluation_data`错误。

**解决方案**：
1. 检查数据库文件路径是否正确配置
2. 确保前端代码能够正确连接到项目根目录下的数据库文件
3. 修复`src/lib/db/index.ts`文件中的数据库连接逻辑：

```typescript
// 修改数据库连接路径解析逻辑
let dbPath = dbUrl.replace("sqlite:///", "");
// 如果是相对路径，相对于项目根目录（而不是当前工作目录）
if (!dbPath.startsWith("/")) {
  // 硬编码路径，确保连接到项目根目录下的test.db文件
  dbPath = path.join("/Users/a111/Desktop/code/youtu-agent", dbPath);
}
```

### Q2: API端点返回空响应

**问题描述**：
前端界面加载成功，但没有显示任何数据，API端点返回空响应。

**解决方案**：
1. 检查数据库连接是否正常
2. 验证数据库中是否有数据
3. 重新构建项目并重启服务器：

```bash
npm run build
npm run start
```

### Q3: 环境变量加载失败

**问题描述**：
前端代码无法读取到`.env`文件中的环境变量。

**解决方案**：
1. 检查`.env`文件路径是否正确
2. 确保在调用`dotenv.config()`时指定了正确的文件路径：

```typescript
dotenv.config({ path: "../../.env" });
```

## 功能说明

前端界面支持以下功能：

1. **实验ID列表**：查看所有可用的实验ID
2. **评估数据**：查看每个实验的评估数据详情
3. **轨迹信息**：查看每个评估的轨迹数据
4. **统计信息**：查看实验的统计数据

## 访问API端点

以下是前端提供的主要API端点：

- `GET /api/exp_ids`：获取所有实验ID
- `GET /api/evaluations/:exp_id`：获取指定实验的评估数据
- `GET /api/evaluations/:exp_id/stats`：获取指定实验的统计数据
- `GET /api/evaluation/:id`：获取指定ID的评估详情
- `GET /api/trajectories`：获取所有轨迹数据
- `GET /api/trajectories/:id`：获取指定ID的轨迹详情

## 注意事项

1. **数据库配置**：
   - SQLite：确保数据库文件存在且包含正确的表结构
   - PostgreSQL：确保数据库服务器正在运行，数据库已创建，并且用户有足够的权限

2. 如果修改了数据库连接配置，需要重新构建项目

3. 前端服务器默认运行在端口3000，如果需要修改端口，可以在启动命令中指定：

```bash
npm run start -p 8080
```

4. 如果遇到跨域问题，可以在`next.config.js`中配置跨域选项

5. **数据库自动切换**：
   - 系统会根据`UTU_DB_URL`的前缀自动切换数据库类型
   - `sqlite:///`前缀使用SQLite数据库
   - 其他前缀（如`postgres://`）使用PostgreSQL数据库
   - 确保评估代码和前端使用相同的数据库类型

# 修复问题Q&A

## Q1: 为什么前端无法连接到项目根目录下的数据库文件？

**问题**：
前端代码使用相对路径连接数据库文件，但当从`frontend/exp_analysis`目录运行时，相对路径解析不正确。

**解决方案**：
修改数据库连接代码，确保相对路径相对于项目根目录解析：

```typescript
// 修改src/lib/db/index.ts文件
let dbPath = dbUrl.replace("sqlite:///", "");
if (!dbPath.startsWith("/")) {
  // 硬编码项目根目录路径
  dbPath = path.join("/Users/a111/Desktop/code/youtu-agent", dbPath);
}
```

## Q2: 为什么API端点返回空响应，即使数据库中有数据？

**问题**：
API端点返回空响应，服务器日志显示找不到表的错误。

**解决方案**：
1. 检查数据库连接路径是否正确
2. 确保构建过程中包含了最新的代码修改
3. 重新构建项目并重启服务器：

```bash
npm run build
npm run start
```

## Q3: 为什么测试脚本可以成功连接数据库，但API端点不能？

**问题**：
直接运行测试脚本可以成功连接数据库并获取数据，但API端点返回空响应。

**解决方案**：
这可能是因为构建过程中没有包含最新的代码修改。需要重新构建项目，确保数据库连接修复被正确应用：

```bash
npm run build
npm run start
```

## Q4: 如何验证前端是否能够正确连接到数据库？

**解决方案**：
1. 创建一个测试脚本，直接查询数据库：

```typescript
// test-db.ts
import { db } from "./src/lib/db";
import { evaluationData } from "./src/lib/db/schema";

async function testDbConnection() {
  const data = await db.select().from(evaluationData).limit(5);
  console.log("Database connection successful:", data);
}

testDbConnection();
```

2. 运行测试脚本：

```bash
npx tsx test-db.ts
```

## Q5: 为什么环境变量`UTU_DB_URL`在前端代码中无法读取？

**问题**：
前端代码无法读取到`.env`文件中的`UTU_DB_URL`环境变量。

**解决方案**：
确保在调用`dotenv.config()`时指定了正确的文件路径：

```typescript
// 在src/lib/db/index.ts文件中
dotenv.config({ path: "../../.env" });
```

## Q6: 如何重启前端服务器以应用代码修改？

**解决方案**：
1. 停止当前运行的服务器：
   - 如果使用终端运行，可以使用`Ctrl+C`停止
   - 如果使用脚本运行，可以找到进程并杀死

2. 重新构建项目：

```bash
npm run build
```

3. 重新启动服务器：

```bash
npm run start
```

## Q7: 如何检查前端服务器的运行状态？

**解决方案**：
1. 查看服务器日志：
   - 如果在终端运行，可以直接查看终端输出
   - 如果使用后台进程运行，可以查看日志文件

2. 测试API端点：

```bash
curl http://localhost:3000/api/exp_ids
```

3. 在浏览器中访问前端界面：

```
http://localhost:3000
```

## Q8: 如何处理前端界面出现的JSON解析错误？

**问题**：
前端界面加载时出现`SyntaxError: Failed to execute 'json' on 'Response': Unexpected end of JSON input`错误。

**解决方案**：
1. 检查API端点是否正常工作：

```bash
curl http://localhost:3000/api/exp_ids
```

2. 如果API端点返回空响应，检查数据库连接和服务器日志
3. 重新构建项目并重启服务器：

```bash
npm run build
npm run start
```

## Q9: 可以使用PostgreSQL作为数据库吗？

**问题**：
是否可以使用PostgreSQL代替SQLite作为数据库？

**解决方案**：
是的，前端完全支持PostgreSQL数据库。只需在`.env`文件中配置PostgreSQL连接URL：

```bash
# PostgreSQL连接URL格式
UTU_DB_URL=postgres://username:password@host:port/database_name

# 示例配置
UTU_DB_URL=postgres://admin:password@localhost:5432/utu_agent
```

系统会根据`UTU_DB_URL`的前缀自动切换数据库类型（`sqlite:///`使用SQLite，其他前缀使用PostgreSQL）。

## Q10: 使用PostgreSQL时需要注意什么？

**问题**：
使用PostgreSQL作为数据库时，需要注意哪些事项？

**解决方案**：
1. 确保PostgreSQL服务器正在运行
2. 确保数据库已经创建
3. 确保配置的用户有足够的权限访问数据库
4. 确保评估代码和前端使用相同的数据库类型和连接URL
5. 如果修改了数据库连接配置，需要重新构建项目：

```bash
npm run build
npm run start
```

# 总结

通过本指南，您应该能够成功部署前端界面并开始查看和分析trace文件。如果遇到任何问题，请参考Q&A部分或查看服务器日志以获取更多信息。

祝您使用愉快！
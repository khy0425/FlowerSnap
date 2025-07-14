# 한글 인코딩 문제 방지 가이드

이 문서는 Blooming Flutter 프로젝트에서 한글 인코딩 문제를 방지하기 위한 완전한 설정 가이드입니다.

## 🔧 이미 적용된 설정들

### 1. PowerShell 인코딩 설정
```powershell
# 현재 세션에 UTF-8 적용
chcp 65001

# PowerShell 프로필에 자동 설정 추가됨
# 위치: C:\Users\[사용자명]\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

### 2. Git 전역 설정
```bash
git config --global core.quotepath false
git config --global i18n.commitencoding utf-8
git config --global i18n.logoutputencoding utf-8
```

### 3. 프로젝트 레벨 설정

#### VS Code 설정 (.vscode/settings.json)
- UTF-8 인코딩 강제
- PowerShell 터미널에 UTF-8 자동 적용
- 줄바꿈 문자 통일 (LF)

#### EditorConfig 설정 (.editorconfig)
- 모든 파일에 UTF-8 charset 적용
- 파일 타입별 일관된 들여쓰기
- 줄바꿈 문자 통일

#### Git Attributes 설정 (.gitattributes)
- 파일별 인코딩 명시적 지정
- 바이너리 파일 구분
- 플랫폼별 줄바꿈 처리

## 🚀 사용 방법

### 새로운 개발 환경에서 설정하기

1. **PowerShell 프로필 설정**
   ```powershell
   # 프로필 파일 생성 (없는 경우)
   if (!(Test-Path -Path $PROFILE)) { 
       New-Item -ItemType File -Path $PROFILE -Force 
   }
   
   # UTF-8 설정 추가
   Add-Content -Path $PROFILE -Value "chcp 65001 > `$null"
   ```

2. **Git 설정 확인**
   ```bash
   git config --global --list | grep -E "(quotepath|encoding)"
   ```

3. **VS Code 확장 설치 권장**
   - EditorConfig for VS Code
   - GitLens
   - Flutter/Dart 확장

### 인코딩 문제 발생 시 해결 방법

1. **터미널 인코딩 확인**
   ```powershell
   chcp  # 65001 (UTF-8)이어야 함
   ```

2. **파일 인코딩 확인**
   ```bash
   file -i [파일명]  # charset=utf-8이어야 함
   ```

3. **강제 UTF-8 변환** (필요한 경우)
   ```bash
   iconv -f euc-kr -t utf-8 [원본파일] > [새파일]
   ```

## ⚠️ 주의사항

1. **항상 UTF-8로 파일 저장**
   - VS Code에서 파일 저장 시 오른쪽 하단 인코딩 확인
   - "UTF-8"이 아닌 경우 클릭하여 변경

2. **Git 커밋 전 확인**
   ```bash
   git status
   git diff --check  # 공백 문자 문제 확인
   ```

3. **새로운 팀원 온보딩 시**
   - 이 가이드 공유
   - 초기 환경 설정 지원
   - 첫 커밋 전 인코딩 검증

## 🔍 문제 진단 체크리스트

- [ ] PowerShell 코드 페이지: 65001 (UTF-8)
- [ ] Git 설정: quotepath=false, commitencoding=utf-8
- [ ] VS Code: files.encoding=utf8
- [ ] 프로젝트 파일들: .editorconfig, .gitattributes 존재
- [ ] 한글 텍스트가 포함된 파일들: UTF-8 인코딩 확인

## 📚 추가 리소스

- [UTF-8 everywhere](http://utf8everywhere.org/)
- [Git 한글 파일명 설정](https://git-scm.com/book/ko/v2)
- [EditorConfig 공식 문서](https://editorconfig.org/)

---

> **중요**: 이 설정들은 프로젝트 전체 팀이 동일하게 적용해야 효과적입니다.
> 새로운 팀원 합류 시 반드시 이 가이드를 따라 환경을 설정하세요. 
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	cognito "github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider/types"
)

// 環境変数から設定を取得
var (
	cognitoRegion     = os.Getenv("COGNITO_REGION")
	cognitoUserPoolID = os.Getenv("COGNITO_USER_POOL_ID")
	cognitoClientID   = os.Getenv("COGNITO_CLIENT_ID")
)

// 共通のCORSヘッダー
var corsHeaders = map[string]string{
	"Content-Type":                     "application/json",
	"Access-Control-Allow-Origin":      "*",
	"Access-Control-Allow-Headers":     "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
	"Access-Control-Allow-Methods":     "OPTIONS,POST,GET",
	"Access-Control-Allow-Credentials": "true",
}

// 環境変数の検証
func validateEnvironment() error {
	if cognitoUserPoolID == "" {
		return errors.New("環境変数 COGNITO_USER_POOL_ID が設定されていません")
	}
	if cognitoClientID == "" {
		return errors.New("環境変数 COGNITO_CLIENT_ID が設定されていません")
	}
	return nil
}

// リクエスト構造体
type SignUpRequest struct {
	Action   string `json:"action"`
	Username string `json:"username"`
	Password string `json:"password"`
	Email    string `json:"email"`
}

type SignInRequest struct {
	Action   string `json:"action"`
	Username string `json:"username"`
	Password string `json:"password"`
}

type VerifyRequest struct {
	Action   string `json:"action"`
	Username string `json:"username"`
	Code     string `json:"code"`
}

// レスポンス構造体
type AuthResponse struct {
	Message string `json:"message,omitempty"`
	Token   string `json:"token,omitempty"`
	Error   string `json:"error,omitempty"`
}

// Cognitoクライアントの初期化
func initCognitoClient() (*cognito.Client, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(cognitoRegion))
	if err != nil {
		return nil, err
	}
	return cognito.NewFromConfig(cfg), nil
}

// サインアップ処理
func handleSignUp(ctx context.Context, req SignUpRequest) (*AuthResponse, error) {
	client, err := initCognitoClient()
	if err != nil {
		return nil, err
	}

	// ユーザー属性の設定
	userAttrs := []types.AttributeType{
		{
			Name:  aws.String("email"),
			Value: aws.String(req.Email),
		},
	}

	// Cognitoにサインアップリクエスト
	_, err = client.SignUp(ctx, &cognito.SignUpInput{
		ClientId:       aws.String(cognitoClientID),
		Username:       aws.String(req.Username),
		Password:       aws.String(req.Password),
		UserAttributes: userAttrs,
	})

	if err != nil {
		return &AuthResponse{Error: err.Error()}, nil
	}

	return &AuthResponse{Message: "ユーザー登録が完了しました。確認コードをメールで確認してください。"}, nil
}

// 確認コード検証
func handleVerify(ctx context.Context, req VerifyRequest) (*AuthResponse, error) {
	client, err := initCognitoClient()
	if err != nil {
		return nil, err
	}

	_, err = client.ConfirmSignUp(ctx, &cognito.ConfirmSignUpInput{
		ClientId:         aws.String(cognitoClientID),
		Username:         aws.String(req.Username),
		ConfirmationCode: aws.String(req.Code),
	})

	if err != nil {
		return &AuthResponse{Error: err.Error()}, nil
	}

	return &AuthResponse{Message: "ユーザーアカウントが確認されました。ログインしてください。"}, nil
}

// サインイン処理
func handleSignIn(ctx context.Context, req SignInRequest) (*AuthResponse, error) {
	client, err := initCognitoClient()
	if err != nil {
		return nil, err
	}

	// 認証パラメータ設定
	authParams := map[string]string{
		"USERNAME": req.Username,
		"PASSWORD": req.Password,
	}

	// Cognitoにログインリクエスト
	resp, err := client.InitiateAuth(ctx, &cognito.InitiateAuthInput{
		AuthFlow:       types.AuthFlowTypeUserPasswordAuth,
		ClientId:       aws.String(cognitoClientID),
		AuthParameters: authParams,
	})

	if err != nil {
		return &AuthResponse{Error: err.Error()}, nil
	}

	// JWTトークンの取得と返却
	return &AuthResponse{
		Message: "ログインに成功しました",
		Token:   *resp.AuthenticationResult.IdToken,
	}, nil
}

// Lambda ハンドラー関数
func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// OPTIONSリクエスト（プリフライトリクエスト）の処理
	if request.HTTPMethod == "OPTIONS" {
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    corsHeaders,
			Body:       "",
		}, nil
	}

	// 環境変数を検証
	if err := validateEnvironment(); err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Headers:    corsHeaders,
			Body:       fmt.Sprintf(`{"error":"%s"}`, err.Error()),
		}, nil
	}

	// リクエストの内容を解析して処理を分岐
	if request.Path == "/auth" {
		// リクエストボディを解析
		var requestBody map[string]interface{}
		if err := json.Unmarshal([]byte(request.Body), &requestBody); err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 400,
				Headers:    corsHeaders,
				Body:       `{"error":"リクエスト形式が不正です"}`,
			}, nil
		}

		// アクション（または操作の種類）を判断
		action, actionExists := requestBody["action"].(string)

		// アクションが明示的に指定されている場合
		if actionExists {
			switch action {
			case "signup":
				var signUpReq SignUpRequest
				if err := json.Unmarshal([]byte(request.Body), &signUpReq); err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 400,
						Headers:    corsHeaders,
						Body:       `{"error":"リクエスト形式が不正です"}`,
					}, nil
				}
				result, err := handleSignUp(ctx, signUpReq)
				if err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 500,
						Headers:    corsHeaders,
						Body:       `{"error":"内部サーバーエラー"}`,
					}, nil
				}
				responseBody, _ := json.Marshal(result)
				return events.APIGatewayProxyResponse{
					StatusCode: 200,
					Headers:    corsHeaders,
					Body:       string(responseBody),
				}, nil

			case "signin":
				var signInReq SignInRequest
				if err := json.Unmarshal([]byte(request.Body), &signInReq); err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 400,
						Headers:    corsHeaders,
						Body:       `{"error":"リクエスト形式が不正です"}`,
					}, nil
				}
				result, err := handleSignIn(ctx, signInReq)
				if err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 500,
						Headers:    corsHeaders,
						Body:       `{"error":"内部サーバーエラー"}`,
					}, nil
				}
				responseBody, _ := json.Marshal(result)
				return events.APIGatewayProxyResponse{
					StatusCode: 200,
					Headers:    corsHeaders,
					Body:       string(responseBody),
				}, nil

			case "verify":
				var verifyReq VerifyRequest
				if err := json.Unmarshal([]byte(request.Body), &verifyReq); err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 400,
						Headers:    corsHeaders,
						Body:       `{"error":"リクエスト形式が不正です"}`,
					}, nil
				}
				result, err := handleVerify(ctx, verifyReq)
				if err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 500,
						Headers:    corsHeaders,
						Body:       `{"error":"内部サーバーエラー"}`,
					}, nil
				}
				responseBody, _ := json.Marshal(result)
				return events.APIGatewayProxyResponse{
					StatusCode: 200,
					Headers:    corsHeaders,
					Body:       string(responseBody),
				}, nil

			default:
				return events.APIGatewayProxyResponse{
					StatusCode: 400,
					Headers:    corsHeaders,
					Body:       `{"error":"不明なアクションです"}`,
				}, nil
			}
		} else {
			// アクションが指定されていない場合、フィールドから推測
			if _, hasEmail := requestBody["email"]; hasEmail {
				// メールフィールドがあればサインアップと判断
				var signUpReq SignUpRequest
				if err := json.Unmarshal([]byte(request.Body), &signUpReq); err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 400,
						Headers:    corsHeaders,
						Body:       `{"error":"リクエスト形式が不正です"}`,
					}, nil
				}
				result, err := handleSignUp(ctx, signUpReq)
				if err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 500,
						Headers:    corsHeaders,
						Body:       `{"error":"内部サーバーエラー"}`,
					}, nil
				}
				responseBody, _ := json.Marshal(result)
				return events.APIGatewayProxyResponse{
					StatusCode: 200,
					Headers:    corsHeaders,
					Body:       string(responseBody),
				}, nil
			} else if _, hasCode := requestBody["code"]; hasCode {
				// コードフィールドがあれば確認と判断
				var verifyReq VerifyRequest
				if err := json.Unmarshal([]byte(request.Body), &verifyReq); err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 400,
						Headers:    corsHeaders,
						Body:       `{"error":"リクエスト形式が不正です"}`,
					}, nil
				}
				result, err := handleVerify(ctx, verifyReq)
				if err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 500,
						Headers:    corsHeaders,
						Body:       `{"error":"内部サーバーエラー"}`,
					}, nil
				}
				responseBody, _ := json.Marshal(result)
				return events.APIGatewayProxyResponse{
					StatusCode: 200,
					Headers:    corsHeaders,
					Body:       string(responseBody),
				}, nil
			} else {
				// それ以外はサインインと判断
				var signInReq SignInRequest
				if err := json.Unmarshal([]byte(request.Body), &signInReq); err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 400,
						Headers:    corsHeaders,
						Body:       `{"error":"リクエスト形式が不正です"}`,
					}, nil
				}
				result, err := handleSignIn(ctx, signInReq)
				if err != nil {
					return events.APIGatewayProxyResponse{
						StatusCode: 500,
						Headers:    corsHeaders,
						Body:       `{"error":"内部サーバーエラー"}`,
					}, nil
				}
				responseBody, _ := json.Marshal(result)
				return events.APIGatewayProxyResponse{
					StatusCode: 200,
					Headers:    corsHeaders,
					Body:       string(responseBody),
				}, nil
			}
		}
	}

	// 他のパスの場合は404を返す
	return events.APIGatewayProxyResponse{
		StatusCode: 404,
		Headers:    corsHeaders,
		Body:       `{"error":"リクエストされたエンドポイントは存在しません"}`,
	}, nil
}

// JWT検証用のハンドラー（他のマイクロサービスでも使える共通ライブラリとして）
func ValidateToken(ctx context.Context, event events.APIGatewayCustomAuthorizerRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	token := event.AuthorizationToken
	if token == "" {
		return events.APIGatewayCustomAuthorizerResponse{}, errors.New("Unauthorized")
	}

	// ここでJWTの検証を行う（AWS SDKを使用）
	// 本来はこの部分にJWTの検証コードを実装します
	// 実際の実装では、Cognitoが発行したJWTの署名検証などを行います

	// 簡易的な例：実際には適切な検証が必要
	if len(token) < 10 {
		return events.APIGatewayCustomAuthorizerResponse{}, errors.New("Unauthorized")
	}

	// 認証成功時はポリシードキュメントを返却
	return generatePolicy("user", "Allow", event.MethodArn), nil
}

// IAMポリシー生成（カスタムオーソライザー用）
func generatePolicy(principalID, effect, resource string) events.APIGatewayCustomAuthorizerResponse {
	authResponse := events.APIGatewayCustomAuthorizerResponse{PrincipalID: principalID}

	if effect != "" && resource != "" {
		authResponse.PolicyDocument = events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Action:   []string{"execute-api:Invoke"},
					Effect:   effect,
					Resource: []string{resource},
				},
			},
		}
	}

	return authResponse
}

func main() {
	lambda.Start(handleRequest)
}

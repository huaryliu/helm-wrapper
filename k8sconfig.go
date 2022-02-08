package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"io"
	"os"
)

func uploadKubeConfig(c *gin.Context) {
	file, _, err := c.Request.FormFile("file")
	if err != nil {
		respErr(c, err)
		return
	}

	path := "/root/.kube"
	fileName := "config"
	//path := "D:/tmp/config"

	_, err = os.Stat(path)

	if os.IsNotExist(err) {
		err = os.MkdirAll(path, os.ModePerm)
		if err != nil {
			fmt.Println("创建目录失败", err)
			respErr(c, err)
			return
		}
	}

	out, err := os.Create(path + "/" + fileName)
	if err != nil {

		respErr(c, err)
		return
	}
	defer out.Close()

	_, err = io.Copy(out, file)
	if err != nil {
		respErr(c, err)
		return
	}

	respOK(c, nil)
}
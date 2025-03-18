#!/bin/bash
set -e

echo "🔧 Добавляем функцию сжатия изображений"

# Путь к файлу редактора профилей
EDITOR_FILE="/root/escort-project/client/src/components/admin/ProfileEditor.tsx"

# Проверяем, существует ли файл
if [ -f "$EDITOR_FILE" ]; then
  cp $EDITOR_FILE ${EDITOR_FILE}.bak_image
  
  # Находим подходящее место для добавления функции сжатия изображений
  # Ищем функцию handlePhotoAdd или похожую
  if grep -q "handlePhotoAdd" "$EDITOR_FILE"; then
    # Добавляем функцию сжатия изображений перед handlePhotoAdd
    sed -i '/handlePhotoAdd/i\  // Функция для сжатия изображения перед загрузкой\n  const compressImage = (file: File): Promise<Blob> => {\n    return new Promise((resolve) => {\n      const reader = new FileReader();\n      reader.onload = (event) => {\n        if (!event.target?.result) return resolve(file);\n        \n        const img = new Image();\n        img.onload = () => {\n          const canvas = document.createElement("canvas");\n          // Уменьшаем размер до 800x600 px\n          const MAX_WIDTH = 800;\n          const MAX_HEIGHT = 600;\n          let width = img.width;\n          let height = img.height;\n          \n          if (width > height) {\n            if (width > MAX_WIDTH) {\n              height *= MAX_WIDTH / width;\n              width = MAX_WIDTH;\n            }\n          } else {\n            if (height > MAX_HEIGHT) {\n              width *= MAX_HEIGHT / height;\n              height = MAX_HEIGHT;\n            }\n          }\n          \n          canvas.width = width;\n          canvas.height = height;\n          \n          const ctx = canvas.getContext("2d");\n          if (!ctx) return resolve(file);\n          \n          ctx.drawImage(img, 0, 0, width, height);\n          \n          // Возвращаем изображение в формате JPEG с качеством 80%\n          canvas.toBlob((blob) => {\n            if (blob) resolve(blob);\n            else resolve(file);\n          }, "image/jpeg", 0.8);\n        };\n        img.src = event.target.result as string;\n      };\n      reader.readAsDataURL(file);\n    });\n  };\n' "$EDITOR_FILE"
    
    # Модифицируем handlePhotoAdd, чтобы использовать сжатие изображений
    sed -i 's/const handlePhotoAdd = .event: React.ChangeEvent<HTMLInputElement>. => {/const handlePhotoAdd = async (event: React.ChangeEvent<HTMLInputElement>) => {/g' "$EDITOR_FILE"
    sed -i '/const files = event.target.files;/a\    // Сжимаем каждое изображение перед добавлением\n    const compressedFiles: string[] = [];\n    \n    if (files) {\n      for (let i = 0; i < files.length; i++) {\n        const file = files[i];\n        try {\n          const compressedBlob = await compressImage(file);\n          const compressedDataUrl = await blobToDataURL(compressedBlob);\n          compressedFiles.push(compressedDataUrl);\n        } catch (error) {\n          console.error("Ошибка при сжатии изображения:", error);\n        }\n      }\n    }\n    \n    // Вспомогательная функция для конвертации Blob в Data URL\n    function blobToDataURL(blob: Blob): Promise<string> {\n      return new Promise((resolve, reject) => {\n        const reader = new FileReader();\n        reader.onload = () => resolve(reader.result as string);\n        reader.onerror = reject;\n        reader.readAsDataURL(blob);\n      });\n    }' "$EDITOR_FILE"
    
    # Заменяем использование files на compressedFiles
    sed -i 's/const newPhotos = \[\...formData.photos\];/const newPhotos = \[\...formData.photos\];/g' "$EDITOR_FILE"
    sed -i '/const newPhotos = \[\...formData.photos\];/a\    // Добавляем сжатые фотографии вместо оригиналов\n    compressedFiles.forEach(dataUrl => newPhotos.push(dataUrl));' "$EDITOR_FILE"
    
    # Комментируем старый код добавления фотографий
    sed -i '/if (files) {/,/}/s/^/\/\/ /' "$EDITOR_FILE"
    
    echo "✅ Функция сжатия изображений добавлена в ProfileEditor"
  else
    echo "⚠️ Функция handlePhotoAdd не найдена в ProfileEditor"
  fi
else
  echo "⚠️ Файл редактора профилей не найден по пути $EDITOR_FILE"
fi

echo "✅ Исправления загрузки изображений завершены"

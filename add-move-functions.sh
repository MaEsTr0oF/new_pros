#!/bin/bash
# Добавляем функции handleMoveUp и handleMoveDown перед функцией handleToggleStatus
sed -i '/const handleToggleStatus = async (profile: Profile) => {/i \
  const handleMoveUp = async (id: number) => {\n\
    try {\n\
      await api.patch(`/admin/profiles/${id}/moveUp`);\n\
      fetchProfiles(); // Обновляем список профилей\n\
    } catch (error) {\n\
      console.error("Error moving profile up:", error);\n\
      setError("Ошибка при перемещении анкеты вверх");\n\
    }\n\
  };\n\
\n\
  const handleMoveDown = async (id: number) => {\n\
    try {\n\
      await api.patch(`/admin/profiles/${id}/moveDown`);\n\
      fetchProfiles(); // Обновляем список профилей\n\
    } catch (error) {\n\
      console.error("Error moving profile down:", error);\n\
      setError("Ошибка при перемещении анкеты вниз");\n\
    }\n\
  };\n\
\n' /root/escort-project/client/src/pages/admin/ProfilesPage.tsx

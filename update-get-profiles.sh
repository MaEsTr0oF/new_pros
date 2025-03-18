#!/bin/bash
# Заменяем строку orderBy в getProfiles
sed -i 's/orderBy: {\n      createdAt: .desc.\n    }/orderBy: {\n      order: "asc"\n    }/' /root/escort-project/server/src/controllers/profileController.ts

#!/bin/bash
# Добавляем импорты ArrowUpIcon и ArrowDownIcon
sed -i '/import {/,/} from .@mui\/icons-material.;/ s/} from .@mui\/icons-material.;/  ArrowUpward as ArrowUpIcon,\n  ArrowDownward as ArrowDownIcon,\n} from "@mui\/icons-material";/' /root/escort-project/client/src/pages/admin/ProfilesPage.tsx

import {
  ArrowUpward as ArrowUpIcon,
  ArrowDownward as ArrowDownIcon,
} from '@mui/icons-material';

// ...существующий код...

const handleMoveUp = async (id: number) => {
  try {
    await api.patch(`/admin/profiles/${id}/moveUp`);
    fetchProfiles(); // Обновляем список профилей
  } catch (error) {
    console.error('Error moving profile up:', error);
    setError('Ошибка при перемещении анкеты вверх');
  }
};

const handleMoveDown = async (id: number) => {
  try {
    await api.patch(`/admin/profiles/${id}/moveDown`);
    fetchProfiles(); // Обновляем список профилей
  } catch (error) {
    console.error('Error moving profile down:', error);
    setError('Ошибка при перемещении анкеты вниз');
  }
};

// ...остальной код...

// В компоненте CardActions добавляем:
<Tooltip title="Переместить вверх">
  <IconButton onClick={() => handleMoveUp(profile.id)} size="small">
    <ArrowUpIcon />
  </IconButton>
</Tooltip>
<Tooltip title="Переместить вниз">
  <IconButton onClick={() => handleMoveDown(profile.id)} size="small">
    <ArrowDownIcon />
  </IconButton>
</Tooltip>

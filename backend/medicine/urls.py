from django.urls import path
from .views import MedicineOfDayView, MusicRecommendView, MedicinePostView, MedicinePostByAIView, MedicineMusicListView, MedicineListView
urlpatterns = [
    path('medicine_of_day/<int:user_id>/<str:day>/<str:weekday>/', MedicineOfDayView.as_view(), name='medicine_of_day'),
    path('music/', MusicRecommendView.as_view(), name='music_recommend'),
    path('music/<int:medicine_id>/', MedicineMusicListView.as_view(), name='medicine_music_list'),
    path('', MedicinePostView.as_view(), name='medicine_post'),
    path('ai/', MedicinePostByAIView.as_view(), name='medicine_post_ai'),
    path('<int:user_id>/', MedicineListView.as_view(), name='medicine_list'),
    path('<int:medicine_id>/music/<int:music_id>/', MedicineMusicListView.as_view(), name='medicine_music_detail'),
]

# trivia/urls.py
from django.urls import path
from .views import CategoryList, fetch_questions

urlpatterns = [
    path('categories/', CategoryList.as_view(), name='category-list'),
    path('questions/', fetch_questions, name='fetch-questions'),
]

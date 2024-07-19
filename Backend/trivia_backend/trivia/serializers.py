# trivia/serializers.py
from rest_framework import serializers
from .models import Category, Question

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'opentdb_id']

class QuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Question
        fields = ['id', 'category', 'question_text', 'difficulty', 'correct_answer', 'incorrect_answers']

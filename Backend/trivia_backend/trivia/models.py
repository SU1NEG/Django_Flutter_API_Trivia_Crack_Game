# trivia/models.py
from django.db import models

class Category(models.Model):
    name = models.CharField(max_length=255)
    opentdb_id = models.IntegerField()

    def __str__(self):
        return self.name


class Question(models.Model):
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    question_text = models.TextField()
    difficulty = models.CharField(max_length=10)
    correct_answer = models.CharField(max_length=255)
    incorrect_answers = models.JSONField()

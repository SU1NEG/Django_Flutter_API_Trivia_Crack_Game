# trivia/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import requests
from .models import Category
from .serializers import CategorySerializer
from django.http import JsonResponse
from rest_framework.decorators import api_view

class CategoryList(APIView):
    def get(self, request):
        # Fetch categories from Open Trivia Database
        url = "https://opentdb.com/api_category.php"
        response = requests.get(url)
        categories = response.json().get('trivia_categories', [])

        for item in categories:
            Category.objects.get_or_create(name=item['name'], opentdb_id=item['id'])

        categories = Category.objects.all()
        category_data = [{"id": category.opentdb_id, "name": category.name} for category in categories]
        return Response(category_data)

@api_view(['GET'])
def fetch_questions(request):
    amount = request.GET.get('amount', 10)
    category = request.GET.get('category')
    difficulty = request.GET.get('difficulty', 'easy')

    opentdb_url = f'https://opentdb.com/api.php?amount={amount}&category={category}&difficulty={difficulty}&type=multiple'
    response = requests.get(opentdb_url)

    if response.status_code == 200:
        data = response.json()
        return JsonResponse(data['results'], safe=False)
    else:
        return JsonResponse({'error': 'Failed to fetch questions'}, status=500)

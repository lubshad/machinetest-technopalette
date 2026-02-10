from rest_framework.authentication import TokenAuthentication
from rest_framework.exceptions import AuthenticationFailed


class TokenOrBearerAuthentication(TokenAuthentication):
    """
    Custom authentication class that supports both Token and Bearer authentication.
    Accepts:
    - Authorization: Token <token_key>
    - Authorization: Bearer <token_key>
    """
    
    def authenticate(self, request):
        # Get the authorization header
        auth = request.META.get('HTTP_AUTHORIZATION', '')
        
        if not auth:
            return None
            
        # Check if it starts with 'Token ' or 'Bearer '
        if auth.startswith('Token '):
            # Use the parent TokenAuthentication for Token format
            return super().authenticate(request)
        elif auth.startswith('Bearer '):
            # Handle Bearer format by extracting the token and using parent method
            # Temporarily modify the header to use Token format
            original_auth = request.META.get('HTTP_AUTHORIZATION')
            request.META['HTTP_AUTHORIZATION'] = auth.replace('Bearer ', 'Token ', 1)
            
            try:
                result = super().authenticate(request)
                return result
            finally:
                # Restore the original header
                if original_auth:
                    request.META['HTTP_AUTHORIZATION'] = original_auth
                else:
                    del request.META['HTTP_AUTHORIZATION']
        
        return None

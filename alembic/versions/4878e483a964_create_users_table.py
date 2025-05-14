"""create users table

Revision ID: 4878e483a964
Revises: 
Create Date: 2025-05-13 15:47:27.542788

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '4878e483a964'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'users',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('email', sa.String(50), nullable=False),
        sa.Column('num_of_hits', sa.Integer, default=0),
    )


def downgrade() -> None:
    """Downgrade schema."""
    pass

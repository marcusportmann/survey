/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package guru.mmp.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Default;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyService</code> class provides the Survey Service implementation.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("JpaQlInspection")
@ApplicationScoped
@Default
public class SurveyService
  implements ISurveyService
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(SurveyService.class);

  /* Entity Manager */
  @PersistenceContext(unitName = "Application")
  private EntityManager entityManager;

  /**
   * Constructs a new <code>SurveyService</code>.
   */
  public SurveyService() {}

  /**
   * Retrieve the survey template identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template
   *
   * @return the survey template identified by the specified ID or <code>null</code> if the
   *         survey template could not be found
   */
  public SurveyTemplate getSurveyTemplate(String id)
    throws SurveyServiceException
  {
    try
    {
      String getSurveyTemplateSQL = "SELECT st FROM SurveyTemplate st WHERE st.id = :id";

      TypedQuery<SurveyTemplate> query = entityManager.createQuery(getSurveyTemplateSQL,
          SurveyTemplate.class);

      query.setParameter("id", id);

      List<SurveyTemplate> surveyTemplates = query.getResultList();

      if (surveyTemplates.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyTemplates.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey template (" + id + ")", e);
    }
  }

  /**
   * Save the survey template.
   *
   * @param surveyTemplate the survey template
   *
   * @return the saved survey template
   *
   * @throws SurveyServiceException
   */
  @Transactional
  public SurveyTemplate saveSurveyTemplate(SurveyTemplate surveyTemplate)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyTemplate))
      {
        surveyTemplate = entityManager.merge(surveyTemplate);
      }

      return surveyTemplate;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey template with ID ("
          + surveyTemplate.getId() + ")", e);
    }
  }
}
